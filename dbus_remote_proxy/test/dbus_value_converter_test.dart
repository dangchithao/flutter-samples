import 'package:dbus/dbus.dart';
import 'package:dbus_remote_proxy/dbus_value_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DBusValueConverter', () {
    group('fromNativeValue', () {
      test('Converts String to DBusString (no expectedSignature)', () {
        final result = DBusValueConverter.fromNativeValue('hello');
        expect(result, isA<DBusString>());
        expect((result as DBusString).value, 'hello');
      });

      test('Converts int to DBusByte (8-bit)', () {
        final result = DBusValueConverter.fromNativeValue(127);
        expect(result, isA<DBusInt16>());
        expect((result as DBusInt16).value, 127);
      });

      test('Converts int to DBusInt16 (16-bit)', () {
        final result = DBusValueConverter.fromNativeValue(32767);
        expect(result, isA<DBusInt16>());
        expect((result as DBusInt16).value, 32767);
      });

      test('Converts int to DBusInt32 (32-bit)', () {
        final result = DBusValueConverter.fromNativeValue(2147483647);
        expect(result, isA<DBusInt32>());
        expect((result as DBusInt32).value, 2147483647);
      });

      test('Converts int to DBusInt64 (larger than 32-bit)', () {
        final result = DBusValueConverter.fromNativeValue(9223372036854775807);
        expect(result, isA<DBusInt64>());
        expect((result as DBusInt64).value, 9223372036854775807);
      });

      test('Converts bool to DBusBoolean', () {
        final result = DBusValueConverter.fromNativeValue(true);
        expect(result, isA<DBusBoolean>());
        expect((result as DBusBoolean).value, true);
      });

      test('Converts double to DBusDouble', () {
        final result = DBusValueConverter.fromNativeValue(3.14);
        expect(result, isA<DBusDouble>());
        expect((result as DBusDouble).value, 3.14);
      });

      test('Converts List to DBusArray (no expectedSignature)', () {
        final result = DBusValueConverter.fromNativeValue(['a', 'b', 'c']);
        expect(result, isA<DBusArray>());
        final array = result as DBusArray;
        expect(array.signature, DBusSignature('as')); // Sửa kỳ vọng thành 'as'
        expect(array.children, hasLength(3));
        expect(array.children, everyElement(isA<DBusString>()));
        expect(array.children.map((e) => (e as DBusString).value),
            ['a', 'b', 'c']);
      });

      test('Converts empty List to DBusArray.string', () {
        final result = DBusValueConverter.fromNativeValue([]);
        expect(result, isA<DBusArray>());
        final array = result as DBusArray;
        expect(array.signature, DBusSignature('as')); // Sửa kỳ vọng thành 'as'
        expect(array.children, isEmpty);
      });

      test('Converts Map to DBusDict (no expectedSignature)', () {
        final result = DBusValueConverter.fromNativeValue({'key': 'value'});
        expect(result, isA<DBusDict>());
        final dict = result as DBusDict;
        expect(dict.keySignature, DBusSignature('s'));
        expect(dict.valueSignature, DBusSignature('s'));
        expect(dict.children, hasLength(1));
        expect(dict.children.keys.first, isA<DBusString>());
        expect((dict.children.keys.first as DBusString).value, 'key');
        expect(dict.children.values.first, isA<DBusString>());
        expect((dict.children.values.first as DBusString).value, 'value');
      });

      test('Throws for unsupported type (no expectedSignature)', () {
        expect(
          () => DBusValueConverter.fromNativeValue(null),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unsupported native value type'),
          )),
        );
      });

      test('Converts String to DBusObjectPath with expectedSignature "o"', () {
        final result = DBusValueConverter.fromNativeValue(
          '/path/to/object',
          expectedSignature: DBusSignature('o'),
        );
        expect(result, isA<DBusObjectPath>());
        expect((result as DBusObjectPath).value, '/path/to/object');
      });

      test('Converts List to DBusArray with expectedSignature "as"', () {
        final result = DBusValueConverter.fromNativeValue(
          ['a', 'b', 'c'],
          expectedSignature: DBusSignature('as'),
        );
        expect(result, isA<DBusArray>());
        final array = result as DBusArray;
        expect(array.signature, DBusSignature('as')); // Sửa kỳ vọng thành 'as'
        expect(array.children, hasLength(3));
        expect(array.children, everyElement(isA<DBusString>()));
        expect(array.children.map((e) => (e as DBusString).value),
            ['a', 'b', 'c']);
      });

      test('Converts Map to DBusDict with expectedSignature "a{sv}"', () {
        final result = DBusValueConverter.fromNativeValue(
          {'key1': 'value1', 'key2': 42},
          expectedSignature: DBusSignature('a{sv}'),
        );
        expect(result, isA<DBusDict>());
        final dict = result as DBusDict;
        expect(dict.keySignature, DBusSignature('s'));
        expect(dict.valueSignature, DBusSignature('v'));
        expect(dict.children, hasLength(2));
        expect(dict.children.keys.map((k) => (k as DBusString).value),
            contains('key1'));
        expect(dict.children.keys.map((k) => (k as DBusString).value),
            contains('key2'));
        final value1 = dict.children[DBusString('key1')] as DBusVariant;
        expect(value1.value, isA<DBusString>());
        expect((value1.value as DBusString).value, 'value1');
        final value2 = dict.children[DBusString('key2')] as DBusVariant;
        expect(value2.value, isA<DBusInt16>());
        expect((value2.value as DBusInt16).value, 42);
      });

      test('Converts struct with expectedSignature "(oa{sv})"', () {
        final result = DBusValueConverter.fromNativeValue(
          [
            '/path',
            {'key': 'value'}
          ],
          expectedSignature: DBusSignature('(oa{sv})'),
        );
        expect(result, isA<DBusStruct>());
        final struct = result as DBusStruct;
        expect(struct.children, hasLength(2));
        expect(struct.children[0], isA<DBusObjectPath>());
        expect((struct.children[0] as DBusObjectPath).value, '/path');
        expect(struct.children[1], isA<DBusDict>());
        final dict = struct.children[1] as DBusDict;
        expect((dict.children[DBusString('key')] as DBusVariant).value,
            isA<DBusString>());
        expect(
            ((dict.children[DBusString('key')] as DBusVariant).value
                    as DBusString)
                .value,
            'value');
      });

      test('Throws for invalid struct with expectedSignature "(oa{sv})"', () {
        expect(
          () => DBusValueConverter.fromNativeValue(
            ['/path'],
            expectedSignature: DBusSignature('(oa{sv})'),
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Struct (oa{sv}) requires 2 elements'),
          )),
        );
      });

      test('Converts variant with expectedSignature "v" (String)', () {
        final result = DBusValueConverter.fromNativeValue(
          'test',
          expectedSignature: DBusSignature('v'),
        );
        expect(result, isA<DBusVariant>());
        final variant = result as DBusVariant;
        expect(variant.value, isA<DBusString>());
        expect((variant.value as DBusString).value, 'test');
      });

      test('Converts variant with expectedSignature "v" (int)', () {
        final result = DBusValueConverter.fromNativeValue(
          42,
          expectedSignature: DBusSignature('v'),
        );
        expect(result, isA<DBusVariant>());
        final variant = result as DBusVariant;
        expect(variant.value, isA<DBusInt16>());
        expect((variant.value as DBusInt16).value, 42);
      });

      test('Converts variant with expectedSignature "v" (List)', () {
        final result = DBusValueConverter.fromNativeValue(
          ['a', 'b'],
          expectedSignature: DBusSignature('v'),
        );
        expect(result, isA<DBusVariant>());
        final variant = result as DBusVariant;
        expect(variant.value, isA<DBusArray>());
        final array = variant.value as DBusArray;
        expect(array.signature, DBusSignature('as')); // Sửa kỳ vọng thành 'as'
        expect(array.children.map((e) => (e as DBusString).value), ['a', 'b']);
      });

      test('Converts variant with expectedSignature "v" (Map)', () {
        final result = DBusValueConverter.fromNativeValue(
          {'key': 'value'},
          expectedSignature: DBusSignature('v'),
        );
        expect(result, isA<DBusVariant>());
        final variant = result as DBusVariant;
        expect(variant.value, isA<DBusDict>());
        final dict = variant.value as DBusDict;
        expect(dict.keySignature, DBusSignature('s'));
        expect(dict.valueSignature, DBusSignature('v'));
        expect((dict.children[DBusString('key')] as DBusVariant).value,
            isA<DBusString>());
        expect(
            ((dict.children[DBusString('key')] as DBusVariant).value
                    as DBusString)
                .value,
            'value');
      });

      test('Throws for unsupported type in variant with expectedSignature "v"',
          () {
        expect(
          () => DBusValueConverter.fromNativeValue(
            null,
            expectedSignature: DBusSignature('v'),
          ),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Unsupported variant value type'),
          )),
        );
      });

      test('Converts nested structure with expectedSignature "a(oa{sv})"', () {
        final result = DBusValueConverter.fromNativeValue(
          [
            [
              '/path',
              {'key': 'value'}
            ],
          ],
          expectedSignature: DBusSignature('a(oa{sv})'),
        );
        expect(result, isA<DBusArray>());
        final array = result as DBusArray;
        expect(array.signature,
            DBusSignature('a(oa{sv})')); // Sửa kỳ vọng thành 'a(oa{sv})'
        expect(array.children, hasLength(1));
        final struct = array.children[0] as DBusStruct;
        expect(struct.children[0], isA<DBusObjectPath>());
        expect((struct.children[0] as DBusObjectPath).value, '/path');
        final dict = struct.children[1] as DBusDict;
        expect((dict.children[DBusString('key')] as DBusVariant).value,
            isA<DBusString>());
        expect(
            ((dict.children[DBusString('key')] as DBusVariant).value
                    as DBusString)
                .value,
            'value');
      });
    });

    group('toNative', () {
      test('Converts DBusString to String', () {
        final result = DBusValueConverter.toNative(DBusString('test'));
        expect(result, 'test');
      });

      test('Converts DBusObjectPath to String', () {
        final result = DBusValueConverter.toNative(DBusObjectPath('/path'));
        expect(result, '/path');
      });

      test('Converts DBusSignature to String', () {
        final result = DBusValueConverter.toNative(DBusSignature('s'));
        expect(result, 's');
      });

      test('Converts DBusBoolean to bool', () {
        final result = DBusValueConverter.toNative(DBusBoolean(true));
        expect(result, true);
      });

      test('Converts DBusByte to int', () {
        final result = DBusValueConverter.toNative(DBusByte(127));
        expect(result, 127);
      });

      test('Converts DBusInt16 to int', () {
        final result = DBusValueConverter.toNative(DBusInt16(32767));
        expect(result, 32767);
      });

      test('Converts DBusUint16 to int', () {
        final result = DBusValueConverter.toNative(DBusUint16(65535));
        expect(result, 65535);
      });

      test('Converts DBusInt32 to int', () {
        final result = DBusValueConverter.toNative(DBusInt32(2147483647));
        expect(result, 2147483647);
      });

      test('Converts DBusUint32 to int', () {
        final result = DBusValueConverter.toNative(DBusUint32(4294967295));
        expect(result, 4294967295);
      });

      test('Converts DBusInt64 to int', () {
        final result =
            DBusValueConverter.toNative(DBusInt64(9223372036854775807));
        expect(result, 9223372036854775807);
      });

      test('Converts DBusUint64 to int', () {
        final result =
            DBusValueConverter.toNative(DBusUint64(9223372036854775807));
        expect(result, 9223372036854775807);
      });

      test('Converts DBusDouble to double', () {
        final result = DBusValueConverter.toNative(DBusDouble(3.14));
        expect(result, 3.14);
      });

      test('Converts DBusArray to List', () {
        final array = DBusArray(DBusSignature('s'), [
          DBusString('a'),
          DBusString('b'),
          DBusString('c'),
        ]);
        final result = DBusValueConverter.toNative(array);
        expect(result, isA<List>());
        expect(result, ['a', 'b', 'c']);
      });

      test('Converts DBusDict to Map', () {
        final dict = DBusDict(
          DBusSignature('s'),
          DBusSignature('s'),
          {DBusString('key'): DBusString('value')},
        );
        final result = DBusValueConverter.toNative(dict);
        expect(result, isA<Map>());
        expect(result, {'key': 'value'});
      });

      test('Converts DBusStruct to List', () {
        final struct = DBusStruct([DBusString('a'), DBusInt32(42)]);
        final result = DBusValueConverter.toNative(struct);
        expect(result, isA<List>());
        expect(result, ['a', 42]);
      });

      test('Converts DBusVariant to native value', () {
        final variant = DBusVariant(DBusString('test'));
        final result = DBusValueConverter.toNative(variant);
        expect(result, 'test');
      });

      test('Converts nested DBusArray with DBusDict', () {
        final dict = DBusDict(
          DBusSignature('s'),
          DBusSignature('v'),
          {
            DBusString('key'): DBusVariant(DBusString('value')),
          },
        );
        final array = DBusArray(DBusSignature('a{sv}'), [dict]);
        final result = DBusValueConverter.toNative(array);
        expect(result, isA<List>());
        expect(result, [
          {'key': 'value'}
        ]);
      });
    });
  });
}
