import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../providers/farm_provider.dart';
import '../models/manual_log.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/user_provider.dart';
import '../models/activity_log.dart';

class LogSearchExportScreen extends StatefulWidget {
  const LogSearchExportScreen({super.key});

  @override
  State<LogSearchExportScreen> createState() => _LogSearchExportScreenState();
}

class _LogSearchExportScreenState extends State<LogSearchExportScreen> {
  String _search = '';
  String _type = 'All';
  List<ManualLog> _filtered = [];
  DateTimeRange? _dateRange;
  String _user = 'All';
  String _animal = 'All';

  void _filter(List<ManualLog> logs) {
    setState(() {
      _filtered = logs.where((l) {
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
    });
  }

  void _exportCSV() {
    final csv = StringBuffer();
    csv.writeln('Type,Timestamp,Animal IDs,Notes,Performed By');
    for (final l in _filtered) {
      csv.writeln(
          '${l.type},${l.timestamp.toIso8601String()},${l.animalIds?.join(";") ?? ''},"${l.notes.replaceAll('"', '""')}",${l.performedBy}');
    }
    Share.share(csv.toString(), subject: 'Log Export');
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farmProv = Provider.of<FarmProvider>(context);
    final farmId = farmProv.selectedFarm?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Search & Export'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: _filtered.isEmpty ? null : _exportCSV,
          ),
        ],
      ),
      body: farmId == null
          ? const Center(child: Text('No farm selected.'))
          : StreamBuilder<List<ManualLog>>(
              stream: db.streamManualLogs(farmId: farmId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final logs = snapshot.data!;
                if (_filtered.isEmpty && _search.isEmpty && _type == 'All') {
                  _filtered = logs;
                }
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
                              decoration: const InputDecoration(
                                  labelText: 'Search by type or notes'),
                              onChanged: (v) {
                                _search = v;
                                _filter(logs);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _type,
                            items: types
                                .map((t) => DropdownMenuItem<String>(
                                    value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) {
                              _type = v!;
                              _filter(logs);
                            },
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _user,
                            items: users
                                .map((u) => DropdownMenuItem<String>(
                                    value: u, child: Text(u)))
                                .toList(),
                            onChanged: (v) {
                              _user = v!;
                              _filter(logs);
                            },
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _animal,
                            items: animals
                                .map((a) => DropdownMenuItem<String>(
                                    value: a, child: Text(a)))
                                .toList(),
                            onChanged: (v) {
                              _animal = v!;
                              _filter(logs);
                            },
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
                                _filter(logs);
                              }
                            },
                            child: Text(_dateRange == null
                                ? 'Date Range'
                                : '${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final l = _filtered[i];
                          return ListTile(
                            title: Text(l.type),
                            subtitle: Text(
                                '${l.timestamp.toLocal().toString().split(' ')[0]} - ${l.notes}'),
                            trailing: Text(l.performedBy),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    // Audit trail display (for admin)
                    if (Provider.of<UserProvider>(context).role == 'admin')
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('Audit Trail (Admin Only)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    if (Provider.of<UserProvider>(context).role == 'admin')
                      Expanded(
                        child: StreamBuilder<List<ActivityLog>>(
                          stream: db.streamActivityLogs(farmId: farmId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();
                            final logs = snapshot.data!;
                            return ListView.builder(
                              itemCount: logs.length,
                              itemBuilder: (context, i) {
                                final log = logs[i];
                                return ListTile(
                                  title: Text('${log.action} ${log.entity}'),
                                  subtitle: Text(
                                      '${log.details} (${log.timestamp.toLocal()})'),
                                  trailing: Text(log.performedBy),
                                );
                              },
                            );
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
