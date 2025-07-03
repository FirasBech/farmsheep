import 'notification_service.dart';

class ReminderService {
  static Future<void> checkAndNotify({required List<DateTime> dueDates}) async {
    final now = DateTime.now();
    for (final due in dueDates) {
      if (due.difference(now).inDays == 0) {
        await NotificationService.showNotification(
          title: 'Reminder',
          body: 'You have a task or animal event due today.',
        );
      }
    }
  }
}
