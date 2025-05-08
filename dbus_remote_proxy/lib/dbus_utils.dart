import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';

class DBusUtils {
  static String systemService = 'system';

  static DBusClient getDBusClientByType(String? type) {
    if (kIsWeb) {
      // In fact, we will not use this dbus client anywhere in the web,
      // just workaround to pass an exception when call DBusClient.system() or DBusClient.session()
      return DBusClient(
        DBusAddress('unix:path=/var/run/dbus/system_bus_socket'),
        introspectable: true,
      );
    }

    return type == DBusUtils.systemService
        ? DBusClient.system()
        : DBusClient.session();
  }
}
