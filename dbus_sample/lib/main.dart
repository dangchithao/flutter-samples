import 'dart:async';
import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_remote_proxy.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

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
