import 'dart:convert';

import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_signal_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DBusSignalConverter Tests', () {
    final baseSignal = DBusSignal(
      sender: 'org.example.Sender',
      path: DBusObjectPath('/org/example/Path'),
      interface: 'org.example.Interface',
      name: 'TestSignal',
      values: [DBusString('Hello'), DBusInt32(42)],
    );

    test('fromJson converts JSON to DBusSignal correctly', () {
      final jsonMap = {
        'sender': 'org.example.Sender',
        'path': '/org/example/Path',
        'interface': 'org.example.Interface',
        'name': 'TestSignal',
        'values': ['Hello', 42],
        'signature': 'sn',
      };
      final signal = DBusSignalConverter.fromJson(jsonMap);

      expect(signal.sender, 'org.example.Sender');
      expect(signal.path.value, '/org/example/Path');
      expect(signal.interface, 'org.example.Interface');
      expect(signal.name, 'TestSignal');
      expect(signal.values, [isA<DBusString>(), isA<DBusInt16>()]);
      expect((signal.values[0] as DBusString).value, 'Hello');
      expect((signal.values[1] as DBusInt16).value, 42);
      expect(signal.signature.value, 'sn');
    });

    test('fromJsonString converts JSON string to DBusSignal correctly', () {
      final jsonString = jsonEncode({
        'sender': 'org.example.Sender',
        'path': '/org/example/Path',
        'interface': 'org.example.Interface',
        'name': 'TestSignal',
        'values': ['Hello', 42],
        'signature': 'sn',
      });
      final signal = DBusSignalConverter.fromJsonString(jsonString);
      expect(signal.sender, 'org.example.Sender');
      expect(signal.path.value, '/org/example/Path');
      expect(signal.interface, 'org.example.Interface');
      expect(signal.name, 'TestSignal');
      expect(signal.values, [isA<DBusString>(), isA<DBusInt16>()]);
      expect((signal.values[0] as DBusString).value, 'Hello');
      expect((signal.values[1] as DBusInt16).value, 42);
      expect(signal.signature.value, 'sn');
    });

    test('fromJson throws exception for missing required fields', () {
      final invalidJson = {
        'path': '/org/example/Path',
        'interface': 'org.example.Interface',
        'name': 'TestSignal',
        'values': ['Hello'],
      };
      expect(() => DBusSignalConverter.fromJson(invalidJson),
          throwsA(isA<Exception>()));
    });

    test('fromJson throws exception for mismatched values and signature', () {
      final invalidJson = {
        'sender': 'org.example.Sender',
        'path': '/org/example/Path',
        'interface': 'org.example.Interface',
        'name': 'TestSignal',
        'values': ['Hello'],
        'signature': 'si',
      };
      expect(() => DBusSignalConverter.fromJson(invalidJson),
          throwsA(isA<Exception>()));
    });

    test('fromJsonString throws exception for invalid JSON', () {
      expect(() => DBusSignalConverter.fromJsonString('invalid json'),
          throwsA(isA<Exception>()));
    });
  });
}
