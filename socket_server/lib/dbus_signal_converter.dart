import 'dart:convert';
import 'package:dbus/dbus.dart';
import 'package:socket_server/dbus_value_converter.dart';

class DBusSignalConverter {
  static Map<String, dynamic> toJson(DBusSignal signal) {
    return {
      'sender': signal.sender,
      'path': signal.path.value,
      'interface': signal.interface,
      'name': signal.name,
      'values': signal.values
          .map((value) => DBusValueConverter.toNative(value))
          .toList(),
      'signature': signal.signature.value,
    };
  }

  static String toJsonString(DBusSignal signal) {
    try {
      return jsonEncode(toJson(signal));
    } catch (e) {
      throw Exception('Failed to encode DBusSignal to JSON: $e');
    }
  }
}
