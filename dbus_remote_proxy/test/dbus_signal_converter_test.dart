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

    test('toJson converts DBusSignal to JSON correctly', () {
      final jsonMap = DBusSignalConverter.toJson(baseSignal);
      expect(jsonMap['sender'], 'org.example.Sender');
      expect(jsonMap['path'], '/org/example/Path');
      expect(jsonMap['interface'], 'org.example.Interface');
      expect(jsonMap['name'], 'TestSignal');
      expect(jsonMap['values'], ['Hello', 42]);
      expect(jsonMap['signature'], 'si');
    });

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

    test('toJsonString converts DBusSignal to JSON string correctly', () {
      final jsonString = DBusSignalConverter.toJsonString(baseSignal);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decodedMap['sender'], 'org.example.Sender');
      expect(decodedMap['path'], '/org/example/Path');
      expect(decodedMap['interface'], 'org.example.Interface');
      expect(decodedMap['name'], 'TestSignal');
      expect(decodedMap['values'], ['Hello', 42]);
      expect(decodedMap['signature'], 'si');
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

    test('toJson handles null sender', () {
      final signalWithNullSender = DBusSignal(
        sender: null,
        path: DBusObjectPath('/org/example/Path'),
        interface: 'org.example.Interface',
        name: 'TestSignal',
        values: [DBusString('Hello')],
      );
      final jsonMap = DBusSignalConverter.toJson(signalWithNullSender);
      expect(jsonMap['sender'], isNull);
      expect(jsonMap['path'], '/org/example/Path');
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

    test('toJsonString handles complex values', () {
      final signalWithList = DBusSignal(
        sender: 'org.example.Sender',
        path: DBusObjectPath('/org/example/Path'),
        interface: 'org.example.Interface',
        name: 'TestSignal',
        values: [
          DBusString('Hello'),
          DBusArray(DBusSignature('s'), [DBusString('World')]),
        ],
      );
      final jsonString = DBusSignalConverter.toJsonString(signalWithList);
      final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decodedMap['values'], [
        'Hello',
        ['World']
      ]);
    });
  });
}
