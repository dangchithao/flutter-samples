## 1.0.0

* Just support for web for first version

## 1.0.1

* Support call with both of session and system bus
* Update function convert native value to Dbus value
* Update README.md

## 1.0.2

* Update function convert native value to Dbus value, support more replySignature
* Update README.md

## 1.0.3
* Refactoring code: DBusRemoteObjectProxy should keep all of the natures of DBusRemoteObject
* Create DBusUtils and DBusValueConvert class
* Add unit test

## 1.0.4
* Create DbusRemoteObjectSignalStreamProxy that allow us listening the signal over a WebSocket connection 
* Create a converter DBusSignalConverter
* Add unit test
* Update README.md

## 1.0.5
* Rename DbusRemoteObjectSignalStreamProxy to DBusRemoteObjectSignalStreamProxy
* Create a new DBusClientProxy
* Update README.md

## 1.0.6
* Support register an Agent to D-Bus