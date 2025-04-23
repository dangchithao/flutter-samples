import 'dart:convert';
import 'dart:io';
import 'package:dbus/dbus.dart';

void main() async {
  final dbusClient = DBusClient.session();
  print('Connected to D-Bus session bus');

  final server = await ServerSocket.bind(InternetAddress.anyIPv4, 3030);
  print('Server running on ${server.address.address}:${server.port}');

  server.listen((Socket client) async {
    print(
      'New client connected: ${client.remoteAddress.address}:${client.remotePort}',
    );

    client.listen(
      (data) async {
        final message = String.fromCharCodes(data).trim();
        print('Received message: $message');

        try {
          final params = jsonDecode(message);
          final command = params['command'];

          if (command == 'get_a11y_address') {
            final dbusRemoteObject = DBusRemoteObject(
              dbusClient,
              name: 'org.a11y.Bus',
              path: DBusObjectPath('/org/a11y/bus'),
            );

            final result = await dbusRemoteObject.callMethod(
              'org.a11y.Bus',
              'GetAddress',
              [],
              replySignature: DBusSignature('s'),
            );

            final address = result.returnValues[0].asString();
            client.write(jsonEncode({'status': 'success', 'address': address}));
          } else {
            client.write(
              jsonEncode({
                'status': 'error',
                'message': 'Unknown command: $command',
              }),
            );
          }
        } catch (e) {
          client.write(
            jsonEncode({'status': 'error', 'message': e.toString()}),
          );
        }
      },
      onError: (error) {
        print('Client error: $error');
        client.close();
      },
      onDone: () {
        print('Client disconnected');
        client.close();
      },
    );
  });

  // Giữ client D-Bus mở
  await dbusClient.ping();
}
