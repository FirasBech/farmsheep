import 'package:flutter/material.dart';
import '../models/farm.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class FarmProvider extends ChangeNotifier {
  final DatabaseService db;
  final AuthService auth;
  List<Farm> _farms = [];
  Farm? _selectedFarm;

  FarmProvider({required this.db, required this.auth});

  List<Farm> get farms => _farms.where((f) => !f.archived).toList();
  List<Farm> get archivedFarms => _farms.where((f) => f.archived).toList();
  Farm? get selectedFarm => _selectedFarm;

  void loadFarms() {
    final userId = auth.currentUser?.uid;
    if (userId == null) return;
    db.streamFarms(userId: userId).listen((list) {
      _farms = list;
      if (_selectedFarm == null && _farms.isNotEmpty) {
        _selectedFarm = _farms.first;
      }
      notifyListeners();
    });
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
    await db.deleteFarm(farmId);
    _farms.removeWhere((f) => f.id == farmId);
    if (_selectedFarm?.id == farmId) {
      _selectedFarm = _farms.isNotEmpty ? _farms.first : null;
    }
    notifyListeners();
  }

  Future<void> archiveFarm(String farmId) async {
    await db.archiveFarm(farmId);
    final index = _farms.indexWhere((f) => f.id == farmId);
    if (index != -1) {
      _farms[index] = Farm(
        id: _farms[index].id,
        name: _farms[index].name,
        address: _farms[index].address,
        ownerId: _farms[index].ownerId,
        partnerIds: _farms[index].partnerIds,
        createdAt: _farms[index].createdAt,
        notes: _farms[index].notes,
        archived: true,
      );
      notifyListeners();
    }
  }
}
