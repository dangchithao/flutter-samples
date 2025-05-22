library;

import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

// A Proxy class extend from DBusClient to abstraction factory methods
class DBusClientProxy extends DBusClient {
  static late String type;
  final DBusAddress _address;
  late DBusObject _registeredObject;

  DBusClientProxy(super.address,
      {super.introspectable = true, super.messageBus = true, super.authClient})
      : _address = address;

  /// Creates a new DBus client to communicate with the system bus.
  factory DBusClientProxy.system({bool introspectable = true}) {
    if (kIsWeb) {
      // In fact, we will not use this dbus client anywhere in the web,
      // just workaround to pass an exception when call DBusClient.system()
      // or DBusClient.session() in web platform
      return DBusClientProxy(
        DBusAddress('unix:path=/system'),
        introspectable: introspectable,
      );
    }

    return DBusClient.system(introspectable: introspectable) as DBusClientProxy;
  }

  /// Creates a new DBus client to communicate with the session bus.
  factory DBusClientProxy.session({bool introspectable = true}) {
    if (kIsWeb) {
      return DBusClientProxy(
        DBusAddress('unix:path=/session'),
        introspectable: introspectable,
      );
    }

    return DBusClient.session(introspectable: introspectable)
        as DBusClientProxy;
  }

  String get serviceType =>
      _address.value == 'unix:path=/system' ? 'system' : 'session';

  @override
  Future<void> registerObject(DBusObject object) async {
    if (kIsWeb) {
      _registeredObject = object;
    } else {
      super.registerObject(object);
    }
  }

  DBusObject get getRegisteredObject => _registeredObject;
}
