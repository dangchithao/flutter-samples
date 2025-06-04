import 'package:dbus/dbus.dart';

class DBusValueConverter {
  static DBusValue fromNativeValue(dynamic value,
      {DBusSignature? expectedSignature}) {
    if (expectedSignature != null) {
      final result = parseNativeValueWithSignature(value, expectedSignature);

      if (result != null) {
        return result;
      }
    }

    if (value is String) {
      if (value.startsWith('/') && !_containsInvalidPathChars(value)) {
        return DBusObjectPath(value);
      }

      List<String> valueSplitted = value.split(':');

      if (valueSplitted.length == 1) {
        return DBusString(value);
      }

      final signature = valueSplitted[0];

      if (signature == 'v') {
        return DBusVariant(createDBusValue(valueSplitted[1], valueSplitted[2]));
      }

      return createDBusValue(signature, valueSplitted[1]);
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

  static DBusValue? parseNativeValueWithSignature(
      dynamic value, DBusSignature signature) {
    if (signature.value.startsWith('a') && value is List) {
      final childSignature = DBusSignature(signature.value.substring(1));
      return DBusArray(
        childSignature,
        value
            .map((v) => fromNativeValue(v, expectedSignature: childSignature))
            .toList(),
      );
    }
    if (signature.value == '(oa{sv})' && value is List) {
      if (value.length != 2) {
        throw Exception('Struct (oa{sv}) requires 2 elements');
      }
      return DBusStruct([
        fromNativeValue(value[0], expectedSignature: DBusSignature('o')),
        fromNativeValue(value[1], expectedSignature: DBusSignature('a{sv}')),
      ]);
    }

    if (signature.value == 'a{sv}' && value is Map) {
      return DBusDict(
        DBusSignature('s'),
        DBusSignature('v'),
        value.map((k, v) => MapEntry(
              DBusString(k.toString()),
              fromNativeValue(v, expectedSignature: DBusSignature('v')),
            )),
      );
    }

    if (signature.value == 'v') {
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
        throw Exception('Unsupported variant value type: ${value.runtimeType}');
      }
    }

    if (signature.value == 'o' && value is String) {
      return DBusObjectPath(value);
    }

    return null;
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

  static dynamic parseDBusValue(DBusValue value) {
    if (value is DBusBoolean) return value.value;
    if (value is DBusByte) return value.value;
    if (value is DBusInt16) return value.value;
    if (value is DBusUint16) return value.value;
    if (value is DBusInt32) return value.value;
    if (value is DBusUint32) return value.value;
    if (value is DBusInt64) return value.value;
    if (value is DBusUint64) return value.value;
    if (value is DBusDouble) return value.value;
    if (value is DBusString) return value.value;
    if (value is DBusObjectPath) return value.value;
    if (value is DBusSignature) return value.value;
    if (value is DBusArray) {
      return value.children.map((child) => parseDBusValue(child)).toList();
    }
    if (value is DBusDict) {
      return value.children.map((key, val) {
        final parsedKey = parseDBusValue(key);
        final parsedVal = parseDBusValue(val);
        return MapEntry(parsedKey, parsedVal);
      });
    }
    if (value is DBusStruct) {
      return value.children.map((child) => parseDBusValue(child)).toList();
    }
    if (value is DBusVariant) {
      return parseDBusValue(value.value);
    }
    throw Exception('Unsupported DBusValue type: ${value.runtimeType}');
  }

  static DBusValue createDBusValue(String signature, String value) {
    switch (signature) {
      case 'b':
        if (value.toLowerCase() == 'true') {
          return DBusBoolean(true);
        }
        if (value.toLowerCase() == 'false') {
          return DBusBoolean(false);
        }
        break;
      case 'y':
        final intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0 && intValue <= 255) {
          return DBusByte(intValue);
        }
        break;
      case 'n':
        final intValue = int.tryParse(value);
        if (intValue != null && intValue >= -32768 && intValue <= 32767) {
          return DBusInt16(intValue);
        }
        break;
      case 'q':
        final intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0 && intValue <= 65535) {
          return DBusUint16(intValue);
        }
        break;
      case 'i':
        final intValue = int.tryParse(value);
        if (intValue != null &&
            intValue >= -2147483648 &&
            intValue <= 2147483647) {
          return DBusInt32(intValue);
        }
        break;
      case 'u':
        final intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0 && intValue <= 4294967295) {
          return DBusUint32(intValue);
        }
        break;
      case 'x':
        final intValue = int.tryParse(value);
        if (intValue != null) return DBusInt64(intValue);
        break;
      case 't':
        final intValue = int.tryParse(value);
        if (intValue != null && intValue >= 0) return DBusUint64(intValue);
        break;
      case 'd':
        final doubleValue = double.tryParse(value);
        if (doubleValue != null) return DBusDouble(doubleValue);
        break;
      case 's':
        return DBusString(value);
      case 'o':
        if (value.startsWith('/') && !_containsInvalidPathChars(value)) {
          return DBusObjectPath(value);
        }
        break;
      case 'g':
        return DBusSignature(value);
      default:
        break;
    }

    throw ArgumentError(
        'Unsupported signature "$signature" or incompatible value type "${value.runtimeType}"');
  }

  static bool _containsInvalidPathChars(String path) {
    return RegExp(r'[^A-Za-z0-9_/]').hasMatch(path);
  }
}
