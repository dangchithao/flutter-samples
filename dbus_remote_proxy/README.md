**DBusRemoteObjectProxy**
==========================

**Introduction**
---------------

DBusRemoteObjectProxy is a proxy class designed to interact with remote D-Bus objects. This class provides a simple way to call methods on remote D-Bus objects, supporting both web and non-web environments.

**Features**
-------------

* Supports calling methods on remote D-Bus objects
* Supports both web and non-web environments
* Uses WebSocket to communicate with the remote D-Bus server in web environments
* Supports timeout and error handling when calling methods

**Installation**
------------

To use DBusRemoteObjectProxy, you need to add the `dbus_remote_proxy` package to your project.

```dart
dependencies:
  dbus_remote_proxy: ^1.0.0
```

**Usage**
------------

To use DBusRemoteObjectProxy, you need to create an instance of this class and call methods on it.

```dart
DBusRemoteObjectProxy proxy = DBusRemoteObjectProxy(
  client: DBusClient.session(),
  name: 'org.freedesktop.DBus',
  path: DBusObjectPath('/org/freedesktop/DBus'),
);

Future<DBusMethodResponse> response = proxy.callMethod(
  'org.freedesktop.DBus',
  'GetId',
  [],
);

print(response);
```

**Support**
------------

If you encounter any issues while using DBusRemoteObjectProxy, please contact us at [dangchithao@gmail.com](mailto:dangchithao@gmail.com).

**License**
------------

DBusRemoteObjectProxy is released under the MIT License. You can use, modify, and distribute this package for free.

**Acknowledgments**
------------

Thank you for using DBusRemoteObjectProxy! We hope that this package will help you interact with remote D-Bus objects efficiently.

**API Documentation**
--------------------

### DBusRemoteObjectProxy

* `DBusRemoteObjectProxy(client, name, path)`: Creates a new instance of DBusRemoteObjectProxy.
* `callMethod(interface, member, values)`: Calls a method on the remote D-Bus object.
* `close()`: Closes the WebSocket connection.
