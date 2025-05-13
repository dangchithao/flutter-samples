# dbus_remote_proxy

A Dart package that provides proxy classes for interacting with D-Bus remote objects through WebSocket connections, especially useful in Flutter web applications where direct D-Bus communication is not available.

This package allows you to abstract D-Bus method calls and signal listening over a WebSocket connection to a backend that bridges between D-Bus and WebSocket (e.g., a custom service running on localhost).

## Features

- **Cross-Platform Support**: Works seamlessly in both web (via WebSocket) and non-web (direct D-Bus) environments.
- **D-Bus Abstraction**: Simplifies interaction with D-Bus services using a proxy class.
- **WebSocket Integration**: Enables Flutter web apps to communicate with a WebSocket server for D-Bus access.
- **Session and System Bus Support**: Handles both session and system D-Bus buses.
- **Error and Timeout Handling**: Includes built-in error management and a 5-second timeout for WebSocket requests.

## Installation

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

### 1. DBusRemoteObjectProxy

This class allows you to call D-Bus methods with WebSocket support on web platforms and native D-Bus on main platforms.

```dart
import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_remote_proxy.dart';

void main() async {
  final proxy = DBusRemoteObjectProxy(
    type: 'system', // or 'session'
    name: 'org.example.Service',
    path: DBusObjectPath('/org/example/Object'),
  );

  try {
    final response = await proxy.callMethod(
      'org.example.Interface',
      'SomeMethod',
      [DBusString('param')],
      replySignature: DBusSignature('s'),
    );
    print('Response: ${response.returnValues}');
  } catch (e) {
    print('Error: $e');
  } finally {
    await proxy.close();
  }
}
```

- **Key Methods**:
  - `callMethod`: Calls a D-Bus method with optional `replySignature`. On web, it sends a JSON request via WebSocket with a 5-second timeout.
  - `close`: Closes the WebSocket connection and cleans up resources.

- **Parameters for `callMethod`**:
  - `interface`: The D-Bus interface (optional).
  - `name`: The method name.
  - `values`: Iterable of `DBusValue` parameters.
  - `replySignature`: Expected return signature (optional).
  - `noReplyExpected`, `noAutoStart`, `allowInteractiveAuthorization`: Passed to native D-Bus calls (ignored on web).

### 2. DbusRemoteObjectSignalStreamProxy

This class listens to D-Bus signals via WebSocket or native D-Bus.

```dart
import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_remote_proxy.dart';
import 'package:dbus_remote_proxy/dbus_remote_object_signal_stream_proxy.dart';

void main() async {
  final proxy = DBusRemoteObjectProxy(
    type: 'system',
    name: 'org.example.Service',
    path: DBusObjectPath('/org/example/Object'),
  );

  final signalProxy = DbusRemoteObjectSignalStreamProxy(
    object: proxy,
    interface: 'org.example.Interface',
    name: 'SignalName',
  );

  try {
    final subscription = signalProxy.listen(
      (signal) {
        print('Received signal: ${signal.name}, values: ${signal.values}');
      },
      onError: (error, stackTrace) {
        print('Error: $error');
      },
      onDone: () {
        print('Stream closed');
      },
    );

    // Cancel subscription when no longer needed
    // subscription.cancel();
  } catch (e) {
    print('Error: $e');
  } finally {
    await signalProxy.close();
  }
}
```

- **Key Methods**:
  - `listen`: Returns a `StreamSubscription<DBusSignal>` to handle incoming signals.
  - `close`: Closes the WebSocket connection and cleans up resources.

### 3. Clean Up

Close the proxy to release resources:

```dart
await proxy.close();
```

## WebSocket Support (Flutter Web)

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

## Notes

- **Timeout Handling**: WebSocket requests have a default 5-second timeout. Adjust by modifying the `timeout` duration in `callMethod`.
- **Error Handling**: Wrap `callMethod` calls in a `try-catch` block to handle exceptions.
- **Resource Cleanup**: Call `close` in the `dispose` method to prevent resource leaks.
- **WebSocket IP/Port**: Default values are `'127.0.0.1'` and `'3030'`, configurable via `--dart-define`.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue on the [GitHub repository](https://github.com/dangchithao/flutter-samples/tree/main/dbus_remote_proxy) for bug reports, feature requests, or suggestions.

## License

This package is licensed under the MIT License. See the [LICENSE](https://en.wikipedia.org/wiki/MIT_License) file for details.

## Support

If you encounter any issues while using DBusRemoteObjectProxy, please contact me at [dangchithao@gmail.com](mailto:dangchithao@gmail.com).