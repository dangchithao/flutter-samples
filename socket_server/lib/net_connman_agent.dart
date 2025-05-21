import 'package:dbus/dbus.dart';

class NetConnmanAgent extends DBusObject {
  final String passphrase;

  NetConnmanAgent({required this.passphrase})
      : super(DBusObjectPath('/net/connman/agent'));

  @override
  Future<DBusMethodResponse> handleMethodCall(DBusMethodCall methodCall) async {
    if (methodCall.interface == 'net.connman.Agent') {
      switch (methodCall.name) {
        case 'RequestInput':
          return DBusMethodSuccessResponse([
            DBusDict.stringVariant({'Passphrase': DBusString(passphrase)}),
          ]);

        case 'Cancel':
          return DBusMethodSuccessResponse([]);

        case 'Release':
          return DBusMethodSuccessResponse([]);
      }
    }

    return DBusMethodErrorResponse.unknownMethod();
  }
}
