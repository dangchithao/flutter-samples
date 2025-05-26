import 'dart:convert';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:socket_server/dbus_signal_converter.dart';
import 'package:socket_server/dbus_value_converter.dart';
import 'package:socket_server/net_connman_agent.dart';

void main() {
  _startSocketServer();
}

void _startSocketServer() async {
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
          final String passphrase = params['passphrase'] ?? '';

          final client = serviceType == 'system' ? systemClient : sessionClient;

          if (passphrase != '') {
            client.registerObject(NetConnmanAgent(passphrase: passphrase));
          }

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
            final replySignature = params['replySignature'] != null
                ? DBusSignature(params['replySignature'])
                : null;
            final values = (params['values'] as List)
                .map((v) => DBusValueConverter.fromNativeValue(v))
                .toList();

            print('[main][values]: $values');

            final result = await object.callMethod(
              interface,
              member,
              values,
              replySignature: replySignature,
            );

            print('[main][result]: $result');

            final returnValues = result.returnValues.map((value) {
              try {
                return DBusValueConverter.parseDBusValue(value);
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
