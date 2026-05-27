import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/notification/presentation/providers/notification_notifier.dart';
import '../core/utils/l10n_extension.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(notificationNotifierProvider);
      if (!state.loaded) {
        ref.read(notificationNotifierProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _scheduleNotification() async {
    if (!_formKey.currentState!.validate()) return;
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.pleasePickTime)));
      return;
    }
    _formKey.currentState!.save();
    final now = DateTime.now();
    final scheduledTime =
        DateTime(now.year, now.month, now.day, _time!.hour, _time!.minute)
            .add(const Duration(days: 1));
    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    final displayTime = _time!.format(context);
    try {
      await ref.read(notificationNotifierProvider.notifier).schedule(
            title: _titleController.text,
            body: _bodyController.text,
            scheduledTime: scheduledTime,
            id: id,
            displayTime: displayTime,
          );
      if (!mounted) return;
      setState(() {
        _titleController.clear();
        _bodyController.clear();
        _time = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.notificationScheduled)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.errorSaving(e.toString()))));
      }
    }
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(notificationNotifierProvider);
    final notifier = ref.read(notificationNotifierProvider.notifier);

    if (!state.loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settings card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(l10n.settingsSectionTitle, Icons.settings_outlined),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.enableNotificationsTitle),
                      subtitle: Text(l10n.enableNotificationsSubtitle),
                      value: state.notificationsEnabled,
                      onChanged: (v) => notifier.setEnabled(v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.dailySummaryTitle),
                      subtitle: Text(l10n.dailySummarySubtitle),
                      value: state.dailySummary,
                      onChanged: (v) => notifier.setDailySummary(v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Schedule card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader(
                        l10n.scheduleReminderSectionTitle, Icons.schedule_outlined),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              labelText: l10n.notificationTitleLabel,
                              prefixIcon: const Icon(Icons.title_outlined),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? l10n.notificationTitleValidation
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bodyController,
                            decoration: InputDecoration(
                              labelText: l10n.notificationMessageLabel,
                              prefixIcon: const Icon(Icons.message_outlined),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? l10n.notificationMessageValidation
                                : null,
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now());
                              if (picked != null) {
                                setState(() => _time = picked);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: _time != null
                                        ? const Color(0xFF2E7D32)
                                        : Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.5)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_outlined,
                                      color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 12),
                                  Text(
                                    _time == null
                                        ? l10n.pickTimeLabel
                                        : _time!.format(context),
                                    style: TextStyle(
                                      color: _time != null
                                          ? const Color(0xFF1B5E20)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_alert_outlined),
                              label: Text(l10n.scheduleNotificationButton),
                              onPressed: state.notificationsEnabled
                                  ? _scheduleNotification
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Scheduled list
            if (state.scheduled.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader(
                          '${l10n.scheduledSectionTitle} (${state.scheduled.length})',
                          Icons.notifications_active_outlined),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.scheduled.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final n = state.scheduled[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Color(0xFF2E7D32),
                                  size: 20),
                            ),
                            title: Text(n['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                                '${n['body']} · ${n['time']}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: IconButton(
                              icon: const Icon(Icons.cancel_outlined,
                                  color: Colors.red),
                              tooltip: l10n.cancelNotificationTooltip,
                              onPressed: () =>
                                  notifier.cancel(n['id'] as int),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.noScheduledNotifications,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
