import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../providers/farm_provider.dart';
import '../models/animal.dart';
import 'package:share_plus/share_plus.dart';

class AnimalSearchExportScreen extends StatefulWidget {
  const AnimalSearchExportScreen({super.key});

  @override
  State<AnimalSearchExportScreen> createState() =>
      _AnimalSearchExportScreenState();
}

class _AnimalSearchExportScreenState extends State<AnimalSearchExportScreen> {
  String _search = '';
  String _type = 'All';
  final String _status = 'All';
  List<Animal> _filtered = [];

  void _filter(List<Animal> animals) {
    setState(() {
      _filtered = animals.where((a) {
        final matchesSearch = _search.isEmpty ||
            a.tagNumber.toString().contains(_search) ||
            a.breed.toLowerCase().contains(_search.toLowerCase());
        final matchesType = _type == 'All' || a.type == _type;
        // Status logic placeholder (add status to Animal model if needed)
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _exportCSV() {
    final csv = StringBuffer();
    csv.writeln('Tag Number,Tag Color,Type,Breed,Birth Date');
    for (final a in _filtered) {
      csv.writeln(
          '${a.tagNumber},${a.tagColor},${a.type},${a.breed},${a.birthDate.toIso8601String()}');
    }
    Share.share(csv.toString(), subject: 'Animal Export');
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farmProv = Provider.of<FarmProvider>(context);
    final farmId = farmProv.selectedFarm?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Search & Export'),
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
          : StreamBuilder<List<Animal>>(
              stream: db.streamAnimals(farmId: farmId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final animals = snapshot.data!;
                if (_filtered.isEmpty && _search.isEmpty && _type == 'All') {
                  _filtered = animals;
                }
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  labelText: 'Search by tag or breed'),
                              onChanged: (v) {
                                _search = v;
                                _filter(animals);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          DropdownButton<String>(
                            value: _type,
                            items: ['All', 'Sheep', 'Goat']
                                .map((t) =>
                                    DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) {
                              _type = v!;
                              _filter(animals);
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final a = _filtered[i];
                          return ListTile(
                            title: Text('#${a.tagNumber} - ${a.type}'),
                            subtitle: Text(
                                '${a.breed}, ${a.birthDate.toLocal().toString().split(' ')[0]}'),
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
