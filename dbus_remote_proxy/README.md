# dbus_remote_proxy

A Dart package that provides a proxy for interacting with D-Bus services, supporting both direct D-Bus calls (in non-web environments) and WebSocket-based communication (for Flutter web applications). This package abstracts D-Bus method calls, offering a flexible and reusable solution for Flutter apps.

## Features
------------

- **Cross-Platform Support**: Works seamlessly in both web (via WebSocket) and non-web (direct D-Bus) environments.
- **D-Bus Abstraction**: Simplifies interaction with D-Bus services using a proxy class.
- **WebSocket Integration**: Enables Flutter web apps to communicate with a WebSocket server for D-Bus access.
- **Session and System Bus Support**: Handles both session and system D-Bus buses.
- **Error and Timeout Handling**: Includes built-in error management and a 5-second timeout for WebSocket requests.

## Installation
------------

Add `dbus_remote_proxy` to your `pubspec.yaml` file:

```yaml
dependencies:
  dbus_remote_proxy: ^1.0.0
```

Then, run the following command to fetch the package:

```bash
flutter pub get
```

## Prerequisites
------------

- **Flutter SDK**: Ensure you have the Flutter SDK installed (supports Flutter apps).
- **D-Bus Dependency**: The `dbus` package is required for direct D-Bus calls. Add it to your `pubspec.yaml`:
  ```yaml
  dependencies:
    dbus: ^0.7.8
  ```
- **WebSocket Dependency**: The `web_socket_channel` package is required for WebSocket support. Add it to your `pubspec.yaml`:
  ```yaml
  dependencies:
    web_socket_channel: ^2.4.0
  ```
- **WebSocket Server (for Web)**: For Flutter web, a WebSocket server is required to bridge D-Bus communication. See the [WebSocket Server Setup](#websocket-server-setup) section.

## Usage
------------

### 1. Import the Package

Import `dbus_remote_proxy` in your Dart file:

```dart
import 'package:dbus_remote_proxy/dbus_remote_proxy.dart';
```

### 2. Initialize the Proxy

Create an instance of `DBusRemoteObjectProxy` with the service type, name, and path:

```dart
final proxy = DBusRemoteObjectProxy(
  type: 'system', // or 'session'
  name: 'your.service',
  path: DBusObjectPath('/your/path'),
);
```

- `type`: The D-Bus bus type (`'system'` or `'session'`).
- `name`: The D-Bus service name (e.g., `'com.platform.AppManager'`).
- `path`: The D-Bus object path (e.g., `'/com/platform/AppManager'`).

### 3. Call D-Bus Methods

Use the `callMethod` function to invoke a D-Bus method:

```dart
final result = await proxy.callMethod(
  'com.platform.AppManager',
  'GetAllList',
  [],
  replySignature: DBusSignature('a{ss}'),
);
```

- `interface`: The D-Bus interface (e.g., `'com.platform.AppManager'`).
- `member`: The method name (e.g., `'GetAllList'`).
- `values`: A list of input parameters as `DBusValue` objects.
- `replySignature`: The expected signature of the return value (e.g., `'a{ss}'`).

### 4. Process the Response

The result is a `DBusMethodResponse`. Extract the data from `returnValues`:

```dart
final appList = result.returnValues[0] as DBusArray;
final apps = appList.children.map((dict) {
  final appDict = dict as DBusDict;
  return Map.fromEntries(appDict.children.entries.map((entry) {
    return MapEntry(
      (entry.key as DBusString).value,
      (entry.value as DBusString).value,
    );
  }));
}).toList();

print(apps.map((app) => 'App: ${app['name']} (ID: ${app['id']})').join('\n'));
```

### 5. Clean Up

Close the proxy to release resources:

```dart
await proxy.close();
```

## WebSocket Support (Flutter Web)
------------

For Flutter web applications, `DBusRemoteObjectProxy` uses WebSocket to communicate with a server that handles D-Bus calls. This is enabled automatically when `kIsWeb` is `true`.

### WebSocket Server Setup

You need a WebSocket server to act as an intermediary between the Flutter web app and D-Bus. Below is an example Dart WebSocket server compatible with this package:

```dart
import 'dart:convert';
import 'package:dbus/dbus.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';

void main() async {
  final sessionClient = DBusClient.session();
  final systemClient = DBusClient.system();

  final handler = webSocketHandler((webSocket) {
    webSocket.stream.listen((message) async {
      try {
        final params = jsonDecode(message);
        final type = params['serviceType'] as String? ?? 'system';
        final name = params['serviceName'] as String;
        final path = params['path'] as String;
        final interface = params['interface'] as String?;
        final member = params['member'] as String;
        final values = (params['values'] as List)
            .map((v) => fromNativeValue(v))
            .toList();
        final replySignature = params['replySignature'] != null
            ? DBusSignature(params['replySignature'])
            : null;

        final client = type == 'system' ? systemClient : sessionClient;
        final object = DBusRemoteObject(client, name: name, path: DBusObjectPath(path));

        final result = await object.callMethod(
          interface,
          member,
          values,
          replySignature: replySignature,
        );

        //TODO: if you have face an error while convert the objects, then please double check here
        final returnValues = result.returnValues.map((v) => v.toNative()).toList();

        webSocket.sink.add(jsonEncode({
          'status': 'success',
          'returnValues': returnValues,
        }));
      } catch (e) {
        webSocket.sink.add(jsonEncode({
          'status': 'error',
          'message': e.toString(),
        }));
      }
    });
  });

  final server = await Handler(handler, address: '0.0.0.0', port: 3030).startServer();
  print('WebSocket server running on ${server.address.host}:${server.port}');
}
```

Run the server with:

```bash
dart run server.dart
```

### WebSocket Configuration

- The WebSocket IP and port are defined via environment variables:
  ```dart
  static const String _ip = String.fromEnvironment('WEBSOCKET_IP', defaultValue: '127.0.0.1');
  static const String _port = String.fromEnvironment('WEBSOCKET_PORT', defaultValue: '3030');
  ```
- Run your Flutter app with these variables:
  ```bash
  flutter run -d chrome --dart-define=WEBSOCKET_IP=[127.0.0.1 | REMOTE_WEBSOCKET_IP] --dart-define=WEBSOCKET_PORT=3030
  ```

## API Reference
------------

### `fromNativeValue`

Converts a native Dart value to a `DBusValue`.

```dart
DBusValue fromNativeValue(dynamic value)
```

- Supports `String`, `int`, `bool`, `double`, `List`, and `Map` types.
- Throws an exception for unsupported types.

### `DBusRemote`

A utility class to create `DBusRemoteObject` instances.

#### `getObjectInstance`

```dart
static DBusRemoteObject? getObjectInstance(String? type, String? name, DBusObjectPath? path)
```

- `type`: The bus type (`'system'` or `'session'`).
- `name`: The D-Bus service name.
- `path`: The D-Bus object path.
- Returns `null` if running on web (`kIsWeb`).

### `DBusRemoteObjectProxy`

#### Constructor

```dart
DBusRemoteObjectProxy({
  required this.type,
  required this.name,
  required this.path,
})
```

- `type`: The D-Bus bus type (`'system'` or `'session'`).
- `name`: The D-Bus service name.
- `path`: The D-Bus object path.

#### Methods

- **`callMethod`**

  ```dart
  Future<DBusMethodResponse> callMethod(
    String? interface,
    String member,
    Iterable<DBusValue> values, {
    DBusSignature? replySignature,
  })
  ```

  Calls a D-Bus method and returns the response.

  - `interface`: The D-Bus interface.
  - `member`: The method name.
  - `values`: Input parameters.
  - `replySignature`: Expected return signature.
  - Throws exceptions for WebSocket or D-Bus errors.

- **`close`**

  ```dart
  Future<void> close()
  ```

  Closes the WebSocket connection (if applicable).

## Example
------------

A complete example of using `dbus_remote_proxy` in a Flutter app:

```dart
import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_remote_proxy.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-Bus Remote Proxy Example',
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
  String _status = 'Ready to fetch data';
  String _result = 'Not retrieved yet';
  DBusRemoteObjectProxy? _proxy;

  @override
  void initState() {
    super.initState();
    _proxy = DBusRemoteObjectProxy(
      type: 'system',
      name: 'com.platform.AppManager',
      path: DBusObjectPath('/com/platform/AppManager'),
    );
  }

  Future<void> _fetchData() async {
    setState(() {
      _status = 'Request sent, waiting for response...';
    });

    try {
      final result = await _proxy!.callMethod(
        'com.platform.AppManager',
        'GetAllList',
        [],
        replySignature: DBusSignature('a{ss}'),
      );

      final appList = result.returnValues[0] as DBusArray;
      final apps = appList.children.map((dict) {
        final appDict = dict as DBusDict;
        return Map.fromEntries(appDict.children.entries.map((entry) {
          return MapEntry(
            (entry.key as DBusString).value,
            (entry.value as DBusString).value,
          );
        }));
      }).toList();

      setState(() {
        _status = 'Data retrieved successfully';
        _result = apps.map((app) => 'App: ${app['name']} (ID: ${app['id']})').join('\n');
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _result = 'Failed to retrieve';
      });
    }
  }

  @override
  void dispose() {
    _proxy?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('D-Bus Remote Proxy Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Fetch Data'),
            ),
            const SizedBox(height: 16),
            Text('Status: $_status'),
            const SizedBox(height: 16),
            Text('Result:\n$_result'),
          ],
        ),
      ),
    );
  }
}
```

## Notes
------------

- **Timeout Handling**: WebSocket requests have a default 5-second timeout. Adjust by modifying the `timeout` duration in `callMethod`.
- **Error Handling**: Wrap `callMethod` calls in a `try-catch` block to handle exceptions.
- **Resource Cleanup**: Call `close` in the `dispose` method to prevent resource leaks.
- **WebSocket IP/Port**: Default values are `'127.0.0.1'` and `'3030'`, configurable via `--dart-define`.

## Contributing
------------

Contributions are welcome! Please submit a pull request or open an issue on the [GitHub repository](https://github.com/dangchithao/flutter-samples/tree/main/dbus_remote_proxy) for bug reports, feature requests, or suggestions.

## License
------------

This package is licensed under the MIT License. See the [LICENSE](https://en.wikipedia.org/wiki/MIT_License) file for details.

## Support
------------

If you encounter any issues while using DBusRemoteObjectProxy, please contact me at [dangchithao@gmail.com](mailto:dangchithao@gmail.com).