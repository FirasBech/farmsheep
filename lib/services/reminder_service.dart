import 'notification_service.dart';

class ReminderService {
  /// Fires a notification for any due date within the next [windowDays] days.
  /// [label] describes what is due (e.g. "health check for 3 animals").
  static Future<void> checkAndNotify({
    required List<DateTime> dueDates,
    String label = 'a farm event',
    int windowDays = 3,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final due in dueDates) {
      final dueDay = DateTime(due.year, due.month, due.day);
      final daysUntil = dueDay.difference(today).inDays;
      if (daysUntil < 0 || daysUntil > windowDays) continue;
      final when = daysUntil == 0
          ? 'today'
          : daysUntil == 1
              ? 'tomorrow'
              : 'in $daysUntil days';
      await NotificationService.showNotification(
        title: 'Farm Reminder',
        body: 'Due $when: $label.',
      );
      return; // one notification per check is enough
    }
  }
}
