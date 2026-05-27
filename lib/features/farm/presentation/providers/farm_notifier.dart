import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/farm.dart';
import '../../../../services/database_service.dart';
import '../../../../services/reminder_service.dart';
import '../../data/repositories/farm_repository_impl.dart';
import '../../domain/repositories/farm_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return FarmRepositoryImpl(DatabaseService());
});

// ── State ──────────────────────────────────────────────────────────────────

class FarmState {
  final List<Farm> farms;
  final Farm? selectedFarm;
  final bool loading;
  /// True after the Firestore stream has emitted at least one result (or error).
  final bool initialized;

  const FarmState({
    this.farms = const [],
    this.selectedFarm,
    this.loading = false,
    this.initialized = false,
  });

  List<Farm> get activeFarms => farms.where((f) => !f.archived).toList();
  List<Farm> get archivedFarms => farms.where((f) => f.archived).toList();

  FarmState copyWith({
    List<Farm>? farms,
    Farm? selectedFarm,
    bool clearSelected = false,
    bool? loading,
    bool? initialized,
  }) =>
      FarmState(
        farms: farms ?? this.farms,
        selectedFarm: clearSelected ? null : (selectedFarm ?? this.selectedFarm),
        loading: loading ?? this.loading,
        initialized: initialized ?? this.initialized,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class FarmNotifier extends Notifier<FarmState> {
  StreamSubscription<List<Farm>>? _sub;

  @override
  FarmState build() {
    ref.onDispose(() => _sub?.cancel());
    return const FarmState();
  }

  FarmRepository get _repo => ref.read(farmRepositoryProvider);

  String? _currentUserId;

  void loadFarms(String userId) {
    // If switching users, reset state entirely so the old user's selectedFarm/farms
    // can't leak into the new session.
    if (_currentUserId != userId) {
      _currentUserId = userId;
      state = const FarmState(loading: true);
    } else {
      state = state.copyWith(loading: true, initialized: false);
    }
    _sub?.cancel();
    _sub = _repo.watchFarms(userId).listen((list) {
      final current = state.selectedFarm;
      // Only keep the prior selectedFarm if it still belongs to the new list.
      Farm? selected;
      if (current != null && list.any((f) => f.id == current.id)) {
        selected = list.firstWhere((f) => f.id == current.id);
      } else if (list.isNotEmpty) {
        selected = list.first;
      }
      state = FarmState(
        farms: list,
        selectedFarm: selected,
        loading: false,
        initialized: true,
      );
      if (selected != null) _checkReminders(selected.id);
    }, onError: (e) {
      state = state.copyWith(loading: false, initialized: true);
    });
  }

  /// Clears farm state. Call on logout so the next user starts fresh.
  void reset() {
    _sub?.cancel();
    _sub = null;
    _currentUserId = null;
    state = const FarmState();
  }

  void selectFarm(Farm farm) {
    state = state.copyWith(selectedFarm: farm);
  }

  Future<void> addFarm(String name, String address,
      {String? notes, required String ownerId}) async {
    final farm = await _repo.createFarm(
        name: name, address: address, ownerId: ownerId, notes: notes);
    final updated = [...state.farms, farm];
    state = state.copyWith(farms: updated, selectedFarm: farm);
  }

  Future<void> updateFarm(Farm farm) async {
    await _repo.updateFarm(farm);
    final updated = [
      for (final f in state.farms) f.id == farm.id ? farm : f
    ];
    state = state.copyWith(
      farms: updated,
      selectedFarm: state.selectedFarm?.id == farm.id ? farm : null,
    );
  }

  Future<void> deleteFarm(String farmId, String callerUid) async {
    await _repo.deleteFarm(farmId, callerUid);
    final updated = state.farms.where((f) => f.id != farmId).toList();
    final newSelected =
        state.selectedFarm?.id == farmId
            ? (updated.isNotEmpty ? updated.first : null)
            : state.selectedFarm;
    state = FarmState(farms: updated, selectedFarm: newSelected);
  }

  Future<void> archiveFarm(String farmId, {String? adminUserId}) async {
    await _repo.archiveFarm(farmId, adminUserId: adminUserId);
    final updated = [
      for (final f in state.farms)
        f.id == farmId ? f.copyWith(archived: true) : f
    ];
    state = state.copyWith(farms: updated);
  }

  Future<void> _checkReminders(String farmId) async {
    try {
      final db = DatabaseService();
      final animals = await db.streamAnimals(farmId: farmId).first;
      final now = DateTime.now();
      final dueDates = animals.map((a) {
        DateTime lastCheck;
        if (a.healthLogs.isNotEmpty) {
          lastCheck = a.healthLogs
              .map((e) => (e['date'] as dynamic).toDate() as DateTime)
              .reduce((a, b) => a.isAfter(b) ? a : b);
        } else {
          lastCheck = a.birthDate;
        }
        return lastCheck.add(const Duration(days: 30));
      }).toList();

      final overdue = dueDates.where((d) => d.isBefore(now)).length;
      final upcoming = dueDates
          .where((d) => d.difference(now).inDays >= 0 && d.difference(now).inDays <= 3)
          .toList();

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
    } catch (_) {}
  }

}

final farmNotifierProvider =
    NotifierProvider<FarmNotifier, FarmState>(FarmNotifier.new);

// Convenience providers
final activeFarmsProvider = Provider<List<Farm>>((ref) {
  return ref.watch(farmNotifierProvider).activeFarms;
});

final selectedFarmRvProvider = Provider<Farm?>((ref) {
  return ref.watch(farmNotifierProvider).selectedFarm;
});
