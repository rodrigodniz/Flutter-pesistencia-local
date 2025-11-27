import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Callback usado na UI (TaskListScreen)
  void Function(bool isOnline)? onStatusChange;

  Future<void> initialize() async {
    final initial = await _connectivity.checkConnectivity();
    _updateStatus(initial);

    _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);

    if (online != _isOnline) {
      _isOnline = online;
      onStatusChange?.call(_isOnline);
    }
  }
}
