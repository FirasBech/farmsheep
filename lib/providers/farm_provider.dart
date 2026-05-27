import 'dart:async';
import 'package:flutter/material.dart';
import '../models/farm.dart';
import '../models/animal.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';
import '../services/reminder_service.dart';

class FarmProvider extends ChangeNotifier {
  final DatabaseService db;
  final AuthService auth;
  List<Farm> _farms = [];
  Farm? _selectedFarm;
  StreamSubscription<List<Farm>>? _sub;

  FarmProvider({required this.db, required this.auth});

  List<Farm> get farms => _farms.where((f) => !f.archived).toList();
  List<Farm> get archivedFarms => _farms.where((f) => f.archived).toList();
  Farm? get selectedFarm => _selectedFarm;

  void loadFarms() {
    final userId = auth.currentUser?.uid;
    if (userId == null) return;
    _sub?.cancel();
    _sub = db.streamFarms(userId: userId).listen((list) {
      _farms = list;
      if (_selectedFarm == null && _farms.isNotEmpty) {
        _selectedFarm = _farms.first;
      }
      notifyListeners();
      if (_selectedFarm != null) {
        _checkReminders(_selectedFarm!.id);
      }
    }, onError: (e) {
      debugPrint('Farm stream error: $e');
    });
  }

  Future<void> _checkReminders(String farmId) async {
    final animals = await db.streamAnimals(farmId: farmId).first;
    final dueDates = <DateTime>[];
    final now = DateTime.now();
    for (final Animal a in animals) {
      DateTime lastCheck;
      if (a.healthLogs.isNotEmpty) {
        final latest = a.healthLogs
            .map((e) => (e['date'] as dynamic).toDate() as DateTime)
            .reduce((a, b) => a.isAfter(b) ? a : b);
        lastCheck = latest;
      } else {
        lastCheck = a.birthDate;
      }
      dueDates.add(lastCheck.add(const Duration(days: 30)));
    }
    final overdue = dueDates.where((d) => d.isBefore(now)).length;
    final upcoming = dueDates.where((d) {
      final days = d.difference(now).inDays;
      return days >= 0 && days <= 3;
    }).toList();
    if (overdue > 0) {
      await ReminderService.checkAndNotify(
        dueDates: [now],
        label: 'health check overdue for $overdue animal${overdue == 1 ? '' : 's'}',
        windowDays: 0,
      );
    } else if (upcoming.isNotEmpty) {
      await ReminderService.checkAndNotify(
        dueDates: upcoming,
        label: 'health check for ${upcoming.length} animal${upcoming.length == 1 ? '' : 's'}',
      );
    }
  }

  void selectFarm(Farm farm) {
    _selectedFarm = farm;
    notifyListeners();
  }

  Future<void> addFarm(String name, String address, {String? notes}) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    final farm = await db.createFarm(
        name: name, address: address, ownerId: userId, notes: notes);
    _farms.add(farm);
    _selectedFarm = farm;
    notifyListeners();
  }

  Future<void> updateFarm(Farm farm) async {
    await db.updateFarm(farm);
    notifyListeners();
  }

  Future<void> deleteFarm(String farmId) async {
    final callerUid = auth.currentUser?.uid ?? '';
    await db.deleteFarm(farmId, callerUid);
    _farms.removeWhere((f) => f.id == farmId);
    if (_selectedFarm?.id == farmId) {
      _selectedFarm = _farms.isNotEmpty ? _farms.first : null;
    }
    notifyListeners();
  }

  Future<void> archiveFarm(String farmId) async {
    final adminUserId = auth.currentUser?.uid;
    await db.archiveFarm(farmId, adminUserId: adminUserId);
    final index = _farms.indexWhere((f) => f.id == farmId);
    if (index != -1) {
      _farms[index] = _farms[index].copyWith(archived: true);
      notifyListeners();
    }
  }
}
