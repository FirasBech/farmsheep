import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static bool skipInitForTests = false;

  static Future<void> init() async {
    if (skipInitForTests) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (skipInitForTests) return;
    const android = AndroidNotificationDetails(
      'default_channel',
      'General',
      channelDescription: 'General notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: android);
    await _notifications.show(id, title, body, details);
  }

  static Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int id = 0,
  }) async {
    const android = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled',
      channelDescription: 'Scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: android);
    tz.initializeTimeZones();
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exact,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Convenience to disable notification plugin setup & calls in tests.
  /// Call early (e.g. in main when `skipFirebase` is true).
  static void disableForTests() {
    skipInitForTests = true;
  }
}
