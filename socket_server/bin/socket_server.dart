import 'dart:io';
import 'package:dbus/dbus.dart';

void main(List<String> arguments) async {
  final DBusClient client = DBusClient.session();

  final server = await ServerSocket.bind('127.0.0.1', 3000);
  print('Listening on ${server.address.address}:${server.port}');

  server.listen((Socket socket) {
    print('Connection from ${socket.remoteAddress.address}:${socket.remotePort}');

    socket.listen((List<int> data) async{
      print('Received data: ${String.fromCharCodes(data)}');

      final message = String.fromCharCodes(data).trim();

      if (message == 'get') {
        socket.write('Hello from the server!');
        try {
          final dbusObject = DBusRemoteObject(
            client,
            name: 'org.a11y.Bus',
            path: DBusObjectPath('/org/a11y/bus'),
          );

          final result = await dbusObject.callMethod(
            'org.a11y.Bus',
            'GetAddress',
            [],
            replySignature: DBusSignature('s'),
          );

          socket.write('Result: $result');
        } catch (e) {
          socket.write('Error: $e');
        }
      } else {
        socket.write('Unknown command: $message');
      }

    }, onDone: () {
      print('Connection closed');
      socket.close();
    }, onError: (error) {
      print('Error: $error');
      socket.close();
    });

  });
  print('Server started on ${server.address.address}:${server.port}');

  await client.ping();
}
