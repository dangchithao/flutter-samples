import 'dart:convert';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

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

void startSocketServer() async {
  final client = DBusClient.session();
  print('Connected to D-Bus session bus');

  final handler = webSocketHandler((webSocket, _) {
    print('New client connected');

    webSocket.stream.listen(
      (message) async {
        print('Received message: $message');

        try {
          final params = jsonDecode(message);
          final String serviceName = params['serviceName'];
          final String path = params['path'];
          final String interface = params['interface'];
          final String member = params['member'];
          final values = (params['values'] as List)
              .map((v) => fromNativeValue(v))
              .toList();
          final replySignature = params['replySignature'] != null
              ? DBusSignature(params['replySignature'])
              : null;

          final object = DBusRemoteObject(
            client,
            name: serviceName,
            path: DBusObjectPath(path),
          );

          final result = await object.callMethod(
            interface,
            member,
            values,
            replySignature: replySignature,
          );

          print('$interface-$member result: $result');

          webSocket.sink.add(jsonEncode({
            'status': 'success',
            'returnValues':
                result.returnValues.map((v) => v.toNative()).toList(),
          }));
        } catch (e) {
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

  await client.ping();
}
