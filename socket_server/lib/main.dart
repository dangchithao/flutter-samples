import 'dart:convert';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:socket_server/dbus_signal_converter.dart';

void main() {
  startSocketServer();
}

DBusValue fromNativeValue(dynamic value) {
  if (value is String) {
    return DBusString(value);
  } else if (value is int) {
    return DBusInt32(value);
  } else if (value is bool) {
    return DBusBoolean(value);
  } else if (value is double) {
    return DBusDouble(value);
  } else if (value is List) {
    return DBusArray(
      DBusSignature(value.isNotEmpty
          ? fromNativeValue(value.first).signature.value
          : 'v'),
      value.map((v) => fromNativeValue(v)).toList(),
    );
  } else if (value is Map) {
    return DBusDict(
      DBusSignature('s'),
      DBusSignature('v'),
      value.map(
          (k, v) => MapEntry(DBusString(k.toString()), fromNativeValue(v))),
    );
  } else {
    throw Exception('Unsupported native value type: ${value.runtimeType}');
  }
}

dynamic parseDBusValue(DBusValue value) {
  if (value is DBusBoolean) return value.value;
  if (value is DBusByte) return value.value;
  if (value is DBusInt16) return value.value;
  if (value is DBusUint16) return value.value;
  if (value is DBusInt32) return value.value;
  if (value is DBusUint32) return value.value;
  if (value is DBusInt64) return value.value;
  if (value is DBusUint64) return value.value;
  if (value is DBusDouble) return value.value;
  if (value is DBusString) return value.value;
  if (value is DBusObjectPath) return value.value;
  if (value is DBusSignature) return value.value;
  if (value is DBusArray) {
    return value.children.map((child) => parseDBusValue(child)).toList();
  }
  if (value is DBusDict) {
    return value.children.map((key, val) {
      final parsedKey = parseDBusValue(key);
      final parsedVal = parseDBusValue(val);
      return MapEntry(parsedKey, parsedVal);
    });
  }
  if (value is DBusStruct) {
    return value.children.map((child) => parseDBusValue(child)).toList();
  }
  if (value is DBusVariant) {
    return parseDBusValue(value.value);
  }
  throw Exception('Unsupported DBusValue type: ${value.runtimeType}');
}

void startSocketServer() async {
  DBusClient sessionClient = DBusClient.session();
  DBusClient systemClient = DBusClient.system();
  print('Connected to D-Bus session/system bus');

  final handler = webSocketHandler((webSocket, _) {
    print('New client connected');

    webSocket.stream.listen(
      (message) async {
        print('Received message: $message');

        try {
          final params = jsonDecode(message);
          final String serviceName = params['serviceName'];
          final String serviceType = params['serviceType'];
          final String path = params['path'];
          final String interface = params['interface'];
          final String member = params['member'];

          final client = serviceType == 'system' ? systemClient : sessionClient;
          final object = DBusRemoteObject(
            client,
            name: serviceName,
            path: DBusObjectPath(path),
          );

          if (member == 'PropertyChanged') {
            final signalStream = DBusRemoteObjectSignalStream(
              object: object,
              interface: interface,
              name: member,
            );

            print('Listening for PropertyChanged...');
            signalStream.listen((DBusSignal signal) {
              print("===> signal $signal");

              webSocket.sink.add(jsonEncode({
                'status': 'success',
                'signal': DBusSignalConverter.toJsonString(signal),
              }));
            });
          } else {
            final values = (params['values'] as List)
                .map((v) => fromNativeValue(v))
                .toList();
            final replySignature = params['replySignature'] != null
                ? DBusSignature(params['replySignature'])
                : null;

            final result = await object.callMethod(
              interface,
              member,
              values,
              replySignature: replySignature,
            );

            print('result: $result');

            final returnValues = result.returnValues.map((value) {
              try {
                return parseDBusValue(value);
              } catch (e) {
                throw Exception('Failed to parse DBusValue: $e');
              }
            }).toList();

            print('returnValues: $returnValues');

            webSocket.sink.add(jsonEncode({
              'status': 'success',
              'returnValues': returnValues,
            }));
          }
        } catch (e) {
          print('Internal Server Error: $e');
          webSocket.sink.add(jsonEncode({
            'status': 'error',
            'message': e.toString(),
          }));
        }
      },
      onError: (error) {
        print('Client error: $error');
      },
      onDone: () {
        print('Client disconnected');
      },
    );
  });

  final HttpServer server =
      await shelf_io.serve(handler, InternetAddress.anyIPv4, 3030);

  print('Serving at ws://${server.address.host}:${server.port}');

  await Future.wait([sessionClient.close(), systemClient.close()]);
}
