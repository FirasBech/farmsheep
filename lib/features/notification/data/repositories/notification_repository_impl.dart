import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/notification_service.dart';
import '../../domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<void> show({
    required String title,
    required String body,
    int id = 0,
  }) =>
      NotificationService.showNotification(title: title, body: body, id: id);

  @override
  Future<void> schedule({
    required String title,
    required String body,
    required DateTime scheduledTime,
    int id = 0,
  }) =>
      NotificationService.scheduleNotification(
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        id: id,
      );

  @override
  Future<void> cancel(int id) => NotificationService.cancel(id);

  @override
  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
  }

  @override
  Future<bool> getDailySummary() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('dailySummary') ?? false;
  }

  @override
  Future<void> setDailySummary(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailySummary', value);
  }

  @override
  Future<List<Map<String, dynamic>>> getScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('scheduledNotifications');
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(
        (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)));
  }

  @override
  Future<void> saveScheduledNotifications(
      List<Map<String, dynamic>> notifications) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scheduledNotifications', jsonEncode(notifications));
  }
}
