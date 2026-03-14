import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../core/runtime/connectivity_service.dart';

class ConnectivityPlusService implements ConnectivityService {
  ConnectivityPlusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<ConnectivityStatus> currentStatus() async {
    final results = await _connectivity.checkConnectivity();
    return _mapResults(results);
  }

  @override
  Stream<ConnectivityStatus> watchStatus() {
    return _connectivity.onConnectivityChanged.map(_mapResults);
  }

  ConnectivityStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      return ConnectivityStatus.offline;
    }

    return ConnectivityStatus.online;
  }
}
