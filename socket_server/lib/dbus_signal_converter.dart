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

  static DBusSignal fromJson(Map<String, dynamic> json) {
    final signature = DBusSignature(json['signature'] as String);
    final values =
        (json['values'] as List<dynamic>).asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      final valueSignature = signature.split()[index];
      return DBusValueConverter.fromNativeValue(value,
          expectedSignature: valueSignature);
    }).toList();

    return DBusSignal(
      sender: json['sender'] as String?,
      path: DBusObjectPath(json['path'] as String),
      interface: json['interface'] as String,
      name: json['name'] as String,
      values: values,
    );
  }

  /// convet JSON string to DBusSignal
  static DBusSignal fromJsonString(String jsonString) {
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJson(jsonMap);
  }

  /// convert DBusSignal to JSON string
  static String toJsonString(DBusSignal signal) {
    return jsonEncode(toJson(signal));
  }
}
