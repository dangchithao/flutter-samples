library;

import 'dart:async';
import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// convert native value to DBusValue
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

class DBusRemote {
  static DBusRemoteObject? getObjectInstance(
      DBusClient? client, String? name, DBusObjectPath? path) {
    if (kIsWeb) {
      return null;
    }

    DBusClient dbusClient = client ?? DBusClient.session();

    return DBusRemoteObject(dbusClient, name: name!, path: path!);
  }
}

// A Proxy class contain DBusRemoteObject to abstraction callMethod layer
class DBusRemoteObjectProxy {
  final DBusRemoteObject? _object;
  WebSocketChannel? _channel;
  final bool _useWebSocket;
  final StreamController<dynamic> _messageController =
      StreamController.broadcast();
  static const String _ip =
      String.fromEnvironment('WEBSOCKET_IP', defaultValue: '127.0.0.1');
  static const String _port =
      String.fromEnvironment('WEBSOCKET_PORT', defaultValue: '3030');
  String? serviceName;
  String? pathValue;

  DBusRemoteObjectProxy(DBusClient? client,
      {String? name, DBusObjectPath? path})
      : _object = DBusRemote.getObjectInstance(client, name, path),
        _useWebSocket = kIsWeb {
    serviceName = name;
    pathValue = path?.value;
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

  Future<DBusMethodResponse> callMethod(
    String? interface,
    String member,
    Iterable<DBusValue> values, {
    DBusSignature? replySignature,
  }) async {
    if (_useWebSocket) {
      if (_channel == null) {
        throw Exception('WebSocket not connected');
      }

      final request = jsonEncode({
        'serviceName': serviceName,
        'path': pathValue,
        'interface': interface,
        'member': member,
        'values': values.map((v) => v.toNative()).toList(),
        'replySignature': replySignature?.value,
      });
      _channel!.sink.add(request);

      // wait message from StreamController
      final completer = Completer<DBusMethodResponse>();
      late StreamSubscription subscription;
      subscription = _messageController.stream.listen(
        (event) {
          try {
            final message = event['message'];
            final result = jsonDecode(message);
            if (result['status'] == 'success') {
              final returnValues = (result['returnValues'] as List)
                  .map((v) => fromNativeValue(v))
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
      if (_object == null) {
        throw Exception('D-Bus object not initialized');
      }
      return await _object.callMethod(interface, member, values,
          replySignature: replySignature);
    }
  }

  Future<void> close() async {
    if (_useWebSocket) {
      _channel?.sink.close();
    }
  }
}
