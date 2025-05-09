library;

import 'dart:async';
import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_utils.dart';
import 'package:dbus_remote_proxy/dbus_value_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// A Proxy class contain DBusRemoteObject to abstraction callMethod layer
class DBusRemoteObjectProxy extends DBusRemoteObject {
  WebSocketChannel? _channel;
  final bool _useWebSocket;
  final StreamController<dynamic> _messageController =
      StreamController.broadcast();
  static const String _ip =
      String.fromEnvironment('WEBSOCKET_IP', defaultValue: '127.0.0.1');
  static const String _port =
      String.fromEnvironment('WEBSOCKET_PORT', defaultValue: '3030');
  String? pathValue;

  final String type;
  final String name;
  final DBusObjectPath path;

  DBusRemoteObjectProxy(
      {required this.type, required this.name, required this.path})
      : _useWebSocket = kIsWeb,
        super(DBusUtils.getDBusClientByType(type), name: name, path: path) {
    pathValue = path.value;
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
  Future<DBusMethodSuccessResponse> callMethod(
      String? interface, String name, Iterable<DBusValue> values,
      {DBusSignature? replySignature,
      bool noReplyExpected = false,
      bool noAutoStart = false,
      bool allowInteractiveAuthorization = false}) async {
    if (_useWebSocket) {
      if (_channel == null) {
        throw Exception('WebSocket not connected');
      }

      final request = jsonEncode({
        'serviceName': this.name,
        'serviceType': type,
        'path': pathValue,
        'interface': interface,
        'member': name,
        'values': values.map((v) => v.toNative()).toList(),
        'replySignature': replySignature?.value,
      });
      _channel!.sink.add(request);

      // wait message from StreamController
      final completer = Completer<DBusMethodSuccessResponse>();
      late StreamSubscription subscription;
      subscription = _messageController.stream.listen(
        (event) {
          try {
            final message = event['message'];
            final result = jsonDecode(message);
            if (result['status'] == 'success') {
              final returnValues = (result['returnValues'] as List)
                  .map((v) => DBusValueConverter.fromNativeValue(v,
                      expectedSignature: replySignature))
                  .toList();
              completer.complete(DBusMethodSuccessResponse(returnValues));
            } else {
              completer.completeError(Exception(result['message']));
            }
          } catch (e) {
            completer.completeError(Exception('Invalid response: $e'));
          } finally {
            subscription.cancel();
          }
        },
        onError: (error) {
          completer.completeError(Exception('WebSocket error: $error'));
          subscription.cancel();
        },
        onDone: () {
          completer.completeError(Exception('Server disconnected'));
          subscription.cancel();
        },
        cancelOnError: true,
      );

      return await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          subscription.cancel();
          throw Exception('Request timed out');
        },
      );
    } else {
      return await super.callMethod(interface, name, values,
          replySignature: replySignature,
          noReplyExpected: noReplyExpected,
          noAutoStart: noAutoStart,
          allowInteractiveAuthorization: allowInteractiveAuthorization);
    }
  }

  Future<void> close() async {
    if (_useWebSocket) {
      _channel?.sink.close();
    }
  }
}
