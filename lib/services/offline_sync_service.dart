import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class OfflineSyncService with ChangeNotifier {
  final bool testMode;
  OfflineSyncService({this.testMode = false}) {
    if (!testMode) _init();
  }

  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  bool _hasConflicts = false;
  bool get hasConflicts => _hasConflicts;
  String? _conflictMessage;
  String? get conflictMessage => _conflictMessage;

  void _init() {
    // connectivity_plus v6+ emits List<ConnectivityResult>
    Connectivity().onConnectivityChanged.listen((results) {
      final online =
          results.isNotEmpty && results.any((r) => r != ConnectivityResult.none);
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
        if (online) _onReconnected();
      }
    });
  }

  void _onReconnected() {
    // Firestore auto-syncs pending writes on reconnect. Just signal briefly.
    _isSyncing = true;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      _isSyncing = false;
      notifyListeners();
    });
  }

  Future<void> manualSync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _hasConflicts = false;
    _conflictMessage = null;
    notifyListeners();
    try {
      // Force Firestore to re-fetch by disabling/re-enabling network.
      await FirebaseFirestore.instance.disableNetwork();
      await FirebaseFirestore.instance.enableNetwork();
    } catch (e) {
      _hasConflicts = true;
      _conflictMessage = 'Sync error. Please check your connection.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

/// Lightweight stub used in tests to bypass Firebase and connectivity logic.
class FakeOfflineSyncService extends OfflineSyncService {
  FakeOfflineSyncService() : super(testMode: true);

  @override
  bool get isOnline => true;

  @override
  bool get isSyncing => false;

  @override
  bool get hasConflicts => false;

  @override
  String? get conflictMessage => null;

  @override
  Future<void> manualSync() async {}
}
