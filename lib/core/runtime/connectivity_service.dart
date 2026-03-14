enum ConnectivityStatus {
  online,
  offline,
}

abstract class ConnectivityService {
  Stream<ConnectivityStatus> watchStatus();

  Future<ConnectivityStatus> currentStatus();
}
