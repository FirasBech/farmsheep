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

  void _init() async {
    await FirebaseFirestore.instance.enablePersistence();
    Connectivity().onConnectivityChanged.listen((status) {
      final online = status != ConnectivityResult.none;
      if (_isOnline != online) {
        _isOnline = online;
        notifyListeners();
        if (online) _syncPending();
      }
    });
  }

  Future<void> _syncPending() async {
    _isSyncing = true;
    notifyListeners();
    // Firestore will auto-sync, but you can force a refresh if needed
    await FirebaseFirestore.instance.clearPersistence();
    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.enablePersistence();
    _isSyncing = false;
    notifyListeners();
  }

  Future<void> manualSync() async {
    _isSyncing = true;
    notifyListeners();
    try {
      // Simulate manual sync logic
      await FirebaseFirestore.instance.clearPersistence();
      await FirebaseFirestore.instance.terminate();
      await FirebaseFirestore.instance.enablePersistence();
      // Simulate conflict detection
      // In a real app, compare local and remote data, set _hasConflicts and _conflictMessage
      _hasConflicts = false;
      _conflictMessage = null;
    } catch (e) {
      _hasConflicts = true;
      _conflictMessage = 'Sync conflict detected. Please review changes.';
    }
    _isSyncing = false;
    notifyListeners();
  }
}

/// Lightweight stub used in tests to bypass Firebase and connectivity logic.
/// It always reports online and not syncing.
/// Placed in lib so both production code (under a `skipFirebase` flag) and
/// tests can reference it without conditional imports.
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
  Future<void> manualSync() async {
    // No-op in tests.
  }
}
