import 'package:flutter/material.dart';
import 'package:dbus/dbus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Bus Accessibility Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Press a button to interact with D-Bus';
  bool _isEnabled = false;
  bool _screenReaderEnabled = false;

  final _client = DBusClient.session();
  late final DBusRemoteObject _dbus;

  @override
  void initState() {
    super.initState();
    _dbus = DBusRemoteObject(
      _client,
      name: 'org.a11y.Bus',
      path: DBusObjectPath('/org/a11y/bus'),
    );
    _loadInitialProperties();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadInitialProperties() async {
    try {
      var isEnabledResult = await _dbus.callMethod(
        'org.freedesktop.DBus.Properties',
        'Get',
        [DBusString('org.a11y.Status'), DBusString('IsEnabled')],
        replySignature: DBusSignature('b'),
      );
      _isEnabled = (isEnabledResult.returnValues[0] as DBusBoolean).value;

      var screenReaderResult = await _dbus.callMethod(
        'org.freedesktop.DBus.Properties',
        'Get',
        [DBusString('org.a11y.Status'), DBusString('ScreenReaderEnabled')],
        replySignature: DBusSignature('b'),
      );
      _screenReaderEnabled =
          (screenReaderResult.returnValues[0] as DBusBoolean).value;

      setState(() {
        _status = 'Properties loaded';
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading properties: $e';
      });
    }
  }

  Future<void> _getAddress() async {
    try {
      var result = await _dbus.callMethod(
        'org.a11y.Bus',
        'GetAddress',
        [],
        replySignature: DBusSignature('s'),
      );
      setState(() {
        _status = 'Address: ${result.returnValues[0].toNative()}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error getting address: $e';
      });
    }
  }

  Future<void> _ping() async {
    try {
      await _dbus.callMethod(
        'org.freedesktop.DBus.Peer',
        'Ping',
        [],
        replySignature: DBusSignature(''),
      );
      setState(() {
        _status = 'Ping successful';
      });
    } catch (e) {
      setState(() {
        _status = 'Error pinging: $e';
      });
    }
  }

  Future<void> _toggleIsEnabled() async {
    try {
      await _dbus.callMethod(
          'org.freedesktop.DBus.Properties',
          'Set',
          [
            DBusString('org.a11y.Status'),
            DBusString('IsEnabled'),
            DBusVariant(DBusBoolean(!_isEnabled)),
          ],
          replySignature: DBusSignature(''));
      setState(() {
        _isEnabled = !_isEnabled;
        _status = 'IsEnabled set to $_isEnabled';
      });
    } catch (e) {
      setState(() {
        _status = 'Error setting IsEnabled: $e';
      });
    }
  }

  Future<void> _toggleScreenReaderEnabled() async {
    try {
      await _dbus.callMethod(
          'org.freedesktop.DBus.Properties',
          'Set',
          [
            DBusString('org.a11y.Status'),
            DBusString('ScreenReaderEnabled'),
            DBusVariant(DBusBoolean(!_screenReaderEnabled)),
          ],
          replySignature: DBusSignature(''));
      setState(() {
        _screenReaderEnabled = !_screenReaderEnabled;
        _status = 'ScreenReaderEnabled set to $_screenReaderEnabled';
      });
    } catch (e) {
      setState(() {
        _status = 'Error setting ScreenReaderEnabled: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('D-Bus Accessibility Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 20),
            Text('IsEnabled: $_isEnabled'),
            Text('ScreenReaderEnabled: $_screenReaderEnabled'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getAddress,
              child: const Text('Get Address'),
            ),
            ElevatedButton(onPressed: _ping, child: const Text('Ping Service')),
            ElevatedButton(
              onPressed: _toggleIsEnabled,
              child: Text('Toggle IsEnabled ($_isEnabled)'),
            ),
            ElevatedButton(
              onPressed: _toggleScreenReaderEnabled,
              child: Text('Toggle ScreenReaderEnabled ($_screenReaderEnabled)'),
            ),
          ],
        ),
      ),
    );
  }
}
