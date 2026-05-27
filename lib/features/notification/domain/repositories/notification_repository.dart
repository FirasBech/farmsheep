abstract class NotificationRepository {
  Future<void> show({
    required String title,
    required String body,
    int id = 0,
  });

  Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int id = 0,
  });

  Future<void> cancel(int id);

  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool value);

  Future<bool> getDailySummary();
  Future<void> setDailySummary(bool value);

  Future<List<Map<String, dynamic>>> getScheduledNotifications();
  Future<void> saveScheduledNotifications(
      List<Map<String, dynamic>> notifications);
}
