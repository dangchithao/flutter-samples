import 'dart:convert';
import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_value_converter.dart';

class DBusSignalConverter {
  static DBusSignal fromJson(Map<String, dynamic> json) {
    try {
      if (json['path'] == null ||
          json['interface'] == null ||
          json['name'] == null ||
          json['signature'] == null ||
          json['values'] == null) {
        throw ArgumentError('Missing required fields in JSON');
      }

      final signature = DBusSignature(json['signature'] as String);
      final valuesJson = json['values'] as List<dynamic>;
      final signatures = signature.split();

      if (valuesJson.length != signatures.length) {
        throw ArgumentError(
            'Number of values (${valuesJson.length}) does not match signature length (${signatures.length})');
      }

      final values = valuesJson.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final valueSignature = signatures[index];

        return DBusValueConverter.fromNativeValue(
          value,
          expectedSignature: valueSignature,
        );
      }).toList();

      return DBusSignal(
        sender: json['sender'] as String?,
        path: DBusObjectPath(json['path'] as String),
        interface: json['interface'] as String,
        name: json['name'] as String,
        values: values,
      );
    } catch (e) {
      throw Exception('Failed to convert JSON to DBusSignal: $e');
    }
  }

  static DBusSignal fromJsonString(String jsonString) {
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to decode JSON string: $e');
    }
  }
}
