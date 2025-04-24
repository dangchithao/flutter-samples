import 'dart:convert';
import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() {
  shelfSebSocket();
}

void serverSocket() async {
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

  await dbusClient.ping();
}

void shelfSebSocket() async {
  final client = DBusClient.session();
  print('Connected to D-Bus session bus');

  final handler = webSocketHandler((webSocket, _) {
    print('New client connected');

    webSocket.stream.listen(
      (message) async {
        print('Received message: $message');

        try {
          final params = jsonDecode(message);
          final command = params['command'];

          if (command == 'get_a11y_address') {
            final object = DBusRemoteObject(
              client,
              name: 'org.a11y.Bus',
              path: DBusObjectPath('/org/a11y/bus'),
            );

            final result = await object.callMethod(
              'org.a11y.Bus',
              'GetAddress',
              [],
              replySignature: DBusSignature('s'),
            );

            final address = result.returnValues[0].asString();
            webSocket.sink.add(jsonEncode({
              'status': 'success',
              'address': address,
            }));
          } else {
            webSocket.sink.add(jsonEncode({
              'status': 'error',
              'message': 'Unknown command: $command',
            }));
          }
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
