library;

import 'dart:async';
import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_remote_proxy.dart';
import 'package:dbus_remote_proxy/dbus_signal_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// A Proxy class extend from DBusRemoteObjectSignalStream to abstraction listen method
class DBusRemoteObjectSignalStreamProxy extends DBusRemoteObjectSignalStream {
  WebSocketChannel? _channel;
  final bool _useWebSocket;
  final StreamController<dynamic> _messageController =
      StreamController.broadcast();
  static const String _ip =
      String.fromEnvironment('WEBSOCKET_IP', defaultValue: '127.0.0.1');
  static const String _port =
      String.fromEnvironment('WEBSOCKET_PORT', defaultValue: '3030');

  final String name;
  final String interface;
  late DBusRemoteObjectProxy object;

  DBusRemoteObjectSignalStreamProxy({
    required this.object,
    required this.name,
    required this.interface,
    super.signature,
  })  : _useWebSocket = kIsWeb,
        super(object: object, interface: interface, name: name) {
    if (_useWebSocket) {
      _connectToWebSocket();

      _channel!.stream.listen(
        (message) {
          _messageController.add({'message': message});
        },
        onError: (error) {
          _messageController.addError(error);
        },
        onDone: () {
          _messageController.close();
        },
      );
    }
  }

  void _connectToWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$_ip:$_port'),
      );
    } catch (e) {
      throw Exception('Failed to connect to WebSocket: $e');
    }
  }

  @override
  StreamSubscription<DBusSignal> listen(
      void Function(DBusSignal signal)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    if (!_useWebSocket) {
      return super.listen(onData,
          onError: onError, onDone: onDone, cancelOnError: cancelOnError);
    }

    if (_channel == null) {
      throw Exception('WebSocket not connected');
    }

    final request = jsonEncode({
      'serviceName': object.name,
      'serviceType': object.type,
      'interface': interface,
      'member': name,
      'path': object.path.value,
    });
    _channel!.sink.add(request);

    return _messageController.stream
        .where((event) => event['message'] != null)
        .map((event) {
      final message = jsonDecode(event['message']);
      final status = message['status'];
      final signal = message['signal'];
      if (status == 'success' && signal != null) {
        return DBusSignalConverter.fromJsonString(signal);
      }

      throw Exception('Not a signal message: $signal');
    }).listen(
      onData,
      onError: (error, stackTrace) {
        print('Signal listen error: $error');
        if (onError != null) {
          onError(error, stackTrace);
        }
      },
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  Future<void> close() async {
    if (_useWebSocket) {
      await _channel?.sink.close();
      await _messageController.close();
    }
  }
}
