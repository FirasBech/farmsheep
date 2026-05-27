import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityStatus extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityStatus() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final online = results.isNotEmpty &&
          results.any((r) => r != ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        notifyListeners();
      }
    });
  }

  // For testing only.
  void setOnlineForTest(bool value) {
    assert(() {
      _isOnline = value;
      notifyListeners();
      return true;
    }());
  }
}
