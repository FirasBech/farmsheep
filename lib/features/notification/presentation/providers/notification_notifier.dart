import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final notificationRepositoryProvider =
    Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl();
});

// ── State ──────────────────────────────────────────────────────────────────

class NotificationState {
  final bool notificationsEnabled;
  final bool dailySummary;
  final List<Map<String, dynamic>> scheduled;
  final bool loaded;

  const NotificationState({
    this.notificationsEnabled = true,
    this.dailySummary = false,
    this.scheduled = const [],
    this.loaded = false,
  });

  NotificationState copyWith({
    bool? notificationsEnabled,
    bool? dailySummary,
    List<Map<String, dynamic>>? scheduled,
    bool? loaded,
  }) =>
      NotificationState(
        notificationsEnabled:
            notificationsEnabled ?? this.notificationsEnabled,
        dailySummary: dailySummary ?? this.dailySummary,
        scheduled: scheduled ?? this.scheduled,
        loaded: loaded ?? this.loaded,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() => const NotificationState();

  NotificationRepository get _repo =>
      ref.read(notificationRepositoryProvider);

  Future<void> load() async {
    final enabled = await _repo.getNotificationsEnabled();
    final daily = await _repo.getDailySummary();
    final scheduled = await _repo.getScheduledNotifications();
    state = state.copyWith(
      notificationsEnabled: enabled,
      dailySummary: daily,
      scheduled: scheduled,
      loaded: true,
    );
  }

  Future<void> setEnabled(bool value) async {
    await _repo.setNotificationsEnabled(value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setDailySummary(bool value) async {
    await _repo.setDailySummary(value);
    state = state.copyWith(dailySummary: value);
  }

  Future<void> show({required String title, required String body}) =>
      _repo.show(title: title, body: body);

  Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required int id,
    required String displayTime,
  }) async {
    await _repo.schedule(
        title: title, body: body, scheduledTime: scheduledTime, id: id);
    final updated = [
      ...state.scheduled,
      {'id': id, 'title': title, 'body': body, 'time': displayTime},
    ];
    await _repo.saveScheduledNotifications(updated);
    state = state.copyWith(scheduled: updated);
  }

  Future<void> cancel(int id) async {
    await _repo.cancel(id);
    final updated =
        state.scheduled.where((n) => n['id'] != id).toList();
    await _repo.saveScheduledNotifications(updated);
    state = state.copyWith(scheduled: updated);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────

final notificationNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
        NotificationNotifier.new);
