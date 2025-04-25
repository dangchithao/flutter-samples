import 'dart:async';
import 'dart:convert';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
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
      String.fromEnvironment('WEBSOCKET_IP', defaultValue: '10.218.141.102');
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
      return await _object!.callMethod(interface, member, values,
          replySignature: replySignature);
    }
  }

  Future<void> close() async {
    if (_useWebSocket) {
      _channel?.sink.close();
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accessibility Bus Client',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const AccessibilityScreen(),
    );
  }
}

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  String _status = 'Ready to get accessibility bus address';
  String _address = 'Not retrieved yet';
  DBusClient? _client;
  DBusRemoteObjectProxy? _object;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _client = kIsWeb ? null : DBusClient.session();
      _object = DBusRemoteObjectProxy(
        _client,
        name: 'org.a11y.Bus',
        path: DBusObjectPath('/org/a11y/bus'),
      );
      setState(() {
        _status = kIsWeb ? 'Connected to WebSocket' : 'Connected to D-Bus';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize: $e';
        _address = 'Failed to retrieve';
      });
    }
  }

  Future<void> _fetchAddress() async {
    setState(() {
      _status = 'Request sent, waiting for response...';
    });

    try {
      final result = await _object!.callMethod(
        'org.a11y.Bus',
        'GetAddress',
        [],
        replySignature: DBusSignature('s'),
      );
      final address = result.returnValues[0].asString();
      setState(() {
        _status = 'Address retrieved successfully';
        _address = address;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _address = 'Failed to retrieve';
      });
    }
  }

  @override
  void dispose() {
    _object?.close();
    _client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Accessibility Bus Address'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _fetchAddress,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Get Accessibility Bus Address'),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Status: $_status',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Address: $_address',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
