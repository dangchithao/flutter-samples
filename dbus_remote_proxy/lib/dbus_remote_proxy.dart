library;

import 'dart:async';
import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

const String systemService = 'system';

// convert native value to DBusValue
DBusValue fromNativeValue(dynamic value) {
  if (value is String) {
    return DBusString(value);
  } else if (value is int) {
    if (value.bitLength <= 8) return DBusByte(value);
    if (value.bitLength <= 16) return DBusInt16(value);
    if (value.bitLength <= 32) return DBusInt32(value);
    return DBusInt64(value);
  } else if (value is bool) {
    return DBusBoolean(value);
  } else if (value is double) {
    return DBusDouble(value);
  } else if (value is List) {
    if (value.isNotEmpty && value.first is Map) {
      return DBusArray(
        DBusSignature('a{ss}'),
        value.map((v) => fromNativeValue(v)).toList(),
      );
    } else if (value.isNotEmpty && value.first is List) {
      return DBusArray(
        DBusSignature('aa{ss}'),
        value.map((v) => fromNativeValue(v)).toList(),
      );
    } else {
      return DBusArray(
        DBusSignature(value.isNotEmpty
            ? fromNativeValue(value.first).signature.value
            : 'v'),
        value.map((v) => fromNativeValue(v)).toList(),
      );
    }
  } else if (value is Map) {
    return DBusDict(
      DBusSignature('s'),
      DBusSignature('s'),
      value.map((k, v) => MapEntry(
            DBusString(k.toString()),
            DBusString(v.toString()),
          )),
    );
  } else {
    throw Exception('Unsupported native value type: ${value.runtimeType}');
  }
}

class DBusRemote {
  static DBusRemoteObject? getObjectInstance(
      String? type, String? name, DBusObjectPath? path) {
    if (kIsWeb) {
      return null;
    }

    DBusClient dbusClient =
        type == systemService ? DBusClient.system() : DBusClient.session();

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
  String? pathValue;

  final String type;
  final String name;
  final DBusObjectPath path;

  DBusRemoteObjectProxy(
      {required this.type, required this.name, required this.path})
      : _object = DBusRemote.getObjectInstance(type, name, path),
        _useWebSocket = kIsWeb {
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
        'serviceName': name,
        'serviceType': type,
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
