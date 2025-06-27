import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<ConnectivityResult> get onConnectivityChanged;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    return _isConnected(connectivityResult);
  }

  @override
  Stream<ConnectivityResult> get onConnectivityChanged {
    return connectivity.onConnectivityChanged;
  }

  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.mobile;
  }
}
