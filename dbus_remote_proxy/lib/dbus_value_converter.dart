import 'package:dbus/dbus.dart';

class DBusValueConverter {
  static DBusValue fromNativeValue(dynamic value,
      {DBusSignature? expectedSignature}) {
    if (expectedSignature != null) {
      if (expectedSignature.value.startsWith('a') && value is List) {
        final childSignature =
            DBusSignature(expectedSignature.value.substring(1));
        return DBusArray(
          childSignature,
          value
              .map((v) => fromNativeValue(v, expectedSignature: childSignature))
              .toList(),
        );
      }
      if (expectedSignature.value == '(oa{sv})' && value is List) {
        if (value.length != 2) {
          throw Exception('Struct (oa{sv}) requires 2 elements');
        }
        return DBusStruct([
          fromNativeValue(value[0], expectedSignature: DBusSignature('o')),
          fromNativeValue(value[1], expectedSignature: DBusSignature('a{sv}')),
        ]);
      }

      if (expectedSignature.value == 'a{sv}' && value is Map) {
        return DBusDict(
          DBusSignature('s'),
          DBusSignature('v'),
          value.map((k, v) => MapEntry(
                DBusString(k.toString()),
                fromNativeValue(v, expectedSignature: DBusSignature('v')),
              )),
        );
      }

      if (expectedSignature.value == 'v') {
        if (value is String) {
          return DBusVariant(DBusString(value));
        } else if (value is int) {
          if (value.bitLength <= 16) return DBusVariant(DBusInt16(value));
          if (value.bitLength <= 32) return DBusVariant(DBusInt32(value));
          return DBusVariant(DBusInt64(value));
        } else if (value is bool) {
          return DBusVariant(DBusBoolean(value));
        } else if (value is double) {
          return DBusVariant(DBusDouble(value));
        } else if (value is List) {
          if (value.isEmpty) return DBusVariant(DBusArray.string([]));
          final childSignature = fromNativeValue(value.first).signature;
          return DBusVariant(DBusArray(
            childSignature,
            value.map((v) => fromNativeValue(v)).toList(),
          ));
        } else if (value is Map) {
          return DBusVariant(DBusDict(
            DBusSignature('s'),
            DBusSignature('v'),
            value.map((k, v) => MapEntry(
                  DBusString(k.toString()),
                  fromNativeValue(v, expectedSignature: DBusSignature('v')),
                )),
          ));
        } else {
          throw Exception(
              'Unsupported variant value type: ${value.runtimeType}');
        }
      }

      if (expectedSignature.value == 'o' && value is String) {
        return DBusObjectPath(value);
      }
    }

    if (value is String) {
      return DBusString(value);
    } else if (value is int) {
      if (value.bitLength <= 16) return DBusInt16(value);
      if (value.bitLength <= 32) return DBusInt32(value);
      return DBusInt64(value);
    } else if (value is bool) {
      return DBusBoolean(value);
    } else if (value is double) {
      return DBusDouble(value);
    } else if (value is List) {
      if (value.isEmpty) return DBusArray.string([]);
      final firstElement = fromNativeValue(value.first);
      return DBusArray(
        firstElement.signature,
        value.map((v) => fromNativeValue(v)).toList(),
      );
    } else if (value is Map) {
      return DBusDict(
        DBusSignature('s'),
        DBusSignature('s'),
        value.map((k, v) => MapEntry(
              DBusString(k.toString()),
              DBusString(v.toString()),
            )),
      );
    } else {
      throw Exception('Unsupported native value type: ${value.runtimeType}');
    }
  }

  static dynamic toNative(DBusValue value) {
    if (value is DBusString ||
        value is DBusBoolean ||
        value is DBusByte ||
        value is DBusInt16 ||
        value is DBusUint16 ||
        value is DBusInt32 ||
        value is DBusUint32 ||
        value is DBusInt64 ||
        value is DBusUint64 ||
        value is DBusDouble) {
      // DBusObjectPath extend from DBusString so it should be placed here
      if (value is DBusObjectPath) {
        return value.value;
      }

      return value.toNative();
    } else if (value is DBusSignature) {
      return value.value;
    }

    if (value is DBusArray) {
      return value.children.map(toNative).toList();
    }

    if (value is DBusDict) {
      return Map.fromEntries(
        value.children.entries
            .map((e) => MapEntry(toNative(e.key), toNative(e.value))),
      );
    }

    if (value is DBusStruct) {
      return value.children.map(toNative).toList();
    }

    if (value is DBusVariant) {
      return toNative(value.value);
    }

    throw UnsupportedError('Unsupported DBusValue type: ${value.runtimeType}');
  }
}
