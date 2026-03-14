import 'dart:async';

import 'package:eipat/core/runtime/connectivity_service.dart';

class FakeConnectivityService implements ConnectivityService {
  FakeConnectivityService({
    ConnectivityStatus initialStatus = ConnectivityStatus.online,
  }) : _status = initialStatus;

  final StreamController<ConnectivityStatus> _controller =
      StreamController<ConnectivityStatus>.broadcast();
  ConnectivityStatus _status;

  @override
  Future<ConnectivityStatus> currentStatus() async => _status;

  void setStatus(ConnectivityStatus status) {
    _status = status;
    _controller.add(status);
  }

  @override
  Stream<ConnectivityStatus> watchStatus() => _controller.stream;
}
