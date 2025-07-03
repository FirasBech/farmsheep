import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _body = '';
  TimeOfDay? _time;
  final List<Map<String, dynamic>> _scheduled = [];
  bool _notificationsEnabled = true;
  bool _dailySummary = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // TODO: Load scheduled notifications from persistent storage if needed
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _dailySummary = prefs.getBool('dailySummary') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('dailySummary', _dailySummary);
  }

  void _scheduleNotification() async {
    if (_formKey.currentState!.validate() && _time != null) {
      _formKey.currentState!.save();
      final now = DateTime.now();
      final scheduledTime =
          DateTime(now.year, now.month, now.day, _time!.hour, _time!.minute)
              .add(const Duration(days: 1));
      final id = DateTime.now().millisecondsSinceEpoch % 100000;
      await NotificationService.scheduleNotification(
        title: _title,
        body: _body,
        scheduledTime: scheduledTime,
        id: id,
      );
      setState(() {
        _scheduled.add({
          'id': id,
          'title': _title,
          'body': _body,
          'time': _time!.format(context),
        });
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Notification scheduled.')));
    }
  }

  void _cancelNotification(int id) async {
    await NotificationService.cancel(id);
    setState(() {
      _scheduled.removeWhere((n) => n['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Settings',
                style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: _notificationsEnabled,
              onChanged: (v) {
                setState(() => _notificationsEnabled = v);
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: const Text('Daily Summary'),
              value: _dailySummary,
              onChanged: (v) {
                setState(() => _dailySummary = v);
                _saveSettings();
              },
            ),
            const Divider(height: 32),
            Text('Schedule a Notification',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Title'),
                    onSaved: (v) => _title = v ?? '',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter a title' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Body'),
                    onSaved: (v) => _body = v ?? '',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter a body' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(_time == null
                          ? 'No time selected'
                          : 'Time: ${_time!.format(context)}'),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(
                              context: context, initialTime: TimeOfDay.now());
                          if (picked != null) setState(() => _time = picked);
                        },
                        child: const Text('Pick Time'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule Notification'),
                    onPressed:
                        _notificationsEnabled ? _scheduleNotification : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Scheduled Notifications',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Expanded(
              child: _scheduled.isEmpty
                  ? const Text('No scheduled notifications.')
                  : ListView.builder(
                      itemCount: _scheduled.length,
                      itemBuilder: (context, i) {
                        final n = _scheduled[i];
                        return ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: Text(n['title'] ?? ''),
                          subtitle: Text('${n['body']} @ ${n['time']}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            tooltip: 'Cancel',
                            onPressed: () => _cancelNotification(n['id']),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
