import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/log/presentation/providers/log_provider.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../models/manual_log.dart';
import '../models/activity_log.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/l10n_extension.dart';

class LogSearchExportScreen extends ConsumerStatefulWidget {
  const LogSearchExportScreen({super.key});

  @override
  ConsumerState<LogSearchExportScreen> createState() =>
      _LogSearchExportScreenState();
}

class _LogSearchExportScreenState
    extends ConsumerState<LogSearchExportScreen> {
  String _search = '';
  String _type = 'All';
  DateTimeRange? _dateRange;
  String _user = 'All';
  String _animal = 'All';

  List<ManualLog> _applyFilters(List<ManualLog> logs) {
    return logs.where((l) {
      final matchesSearch = _search.isEmpty ||
          l.notes.toLowerCase().contains(_search.toLowerCase()) ||
          l.type.toLowerCase().contains(_search.toLowerCase());
      final matchesType = _type == 'All' || l.type == _type;
      final matchesUser = _user == 'All' || l.performedBy == _user;
      final matchesAnimal =
          _animal == 'All' || (l.animalIds?.contains(_animal) ?? false);
      final matchesDate = _dateRange == null ||
          (_dateRange!.start.isBefore(l.timestamp) &&
              _dateRange!.end.isAfter(l.timestamp));
      return matchesSearch &&
          matchesType &&
          matchesUser &&
          matchesAnimal &&
          matchesDate;
    }).toList();
  }

  void _exportCSV(List<ManualLog> filtered) {
    final csv = StringBuffer();
    csv.writeln('Type,Timestamp,Animal IDs,Notes,Performed By');
    for (final l in filtered) {
      csv.writeln(
          '${l.type},${l.timestamp.toIso8601String()},${l.animalIds?.join(";") ?? ''},"${l.notes.replaceAll('"', '""')}",${l.performedBy}');
    }
    SharePlus.instance
        .share(ShareParams(text: csv.toString(), subject: 'Log Export'));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final farmId = ref.watch(farmNotifierProvider).selectedFarm?.id;
    final role = ref.watch(authNotifierProvider).role;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logSearchExportTitle),
      ),
      body: farmId == null
          ? Center(child: Text(l10n.noFarmSelected))
          : ref.watch(logsStreamProvider(farmId)).when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (logs) {
                  final filtered = _applyFilters(logs);
                  final types = [
                    'All',
                    ...{for (final l in logs) l.type}
                  ];
                  final users = [
                    'All',
                    ...{for (final l in logs) l.performedBy}
                  ];
                  final animals = [
                    'All',
                    ...{for (final l in logs) ...(l.animalIds ?? [])}
                  ];
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                    labelText: l10n.searchByTypeOrNotes),
                                onChanged: (v) =>
                                    setState(() => _search = v),
                              ),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: _type,
                              items: types
                                  .map((t) => DropdownMenuItem<String>(
                                      value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _type = v!),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: _user,
                              items: users
                                  .map((u) => DropdownMenuItem<String>(
                                      value: u, child: Text(u)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _user = v!),
                            ),
                            const SizedBox(width: 16),
                            DropdownButton<String>(
                              value: _animal,
                              items: animals
                                  .map((a) => DropdownMenuItem<String>(
                                      value: a, child: Text(a)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _animal = v!),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                final picked = await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setState(() => _dateRange = picked);
                                }
                              },
                              child: Text(_dateRange == null
                                  ? l10n.dateRangeButton
                                  : '${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.download),
                              tooltip: l10n.exportCsvTooltip,
                              onPressed: filtered.isEmpty
                                  ? null
                                  : () => _exportCSV(filtered),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final l = filtered[i];
                            return ListTile(
                              title: Text(l.type),
                              subtitle: Text(
                                  '${l.timestamp.toLocal().toString().split(' ')[0]} - ${l.notes}'),
                              trailing: Text(l.performedBy),
                            );
                          },
                        ),
                      ),
                      if (role == 'admin') ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(l10n.auditTrailHeader,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Expanded(
                          child: ref
                              .watch(activityLogsStreamProvider(farmId))
                              .when(
                                loading: () => const SizedBox(),
                                error: (_, __) => const SizedBox(),
                                data: (actLogs) => _AuditList(
                                    logs: actLogs),
                              ),
                        ),
                      ],
                    ],
                  );
                },
              ),
    );
  }
}

class _AuditList extends StatelessWidget {
  final List<ActivityLog> logs;
  const _AuditList({required this.logs});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, i) {
        final log = logs[i];
        return ListTile(
          title: Text('${log.action} ${log.entity}'),
          subtitle:
              Text('${log.details} (${log.timestamp.toLocal()})'),
          trailing: Text(log.performedBy),
        );
      },
    );
  }
}
