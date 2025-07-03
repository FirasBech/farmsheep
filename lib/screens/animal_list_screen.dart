import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../models/animal.dart';
import '../providers/farm_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  String _search = '';
  String? _typeFilter;
  String? _statusFilter;

  Future<void> _exportToCSV(List<Animal> animals) async {
    final headers = ['Tag', 'Color', 'Type', 'Breed', 'BirthDate', 'Status'];
    final rows = animals
        .map((a) => [
              a.tagId,
              a.tagColor,
              a.type,
              a.breed,
              a.birthDate.toIso8601String(),
              a.status,
            ])
        .toList();
    final csv = StringBuffer();
    csv.writeln(headers.join(','));
    for (final row in rows) {
      csv.writeln(row.map((e) => '"$e"').join(','));
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/animals_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv.toString());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to ${file.path}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context, listen: false);
    final farmProv = Provider.of<FarmProvider>(context);
    final farmId = farmProv.selectedFarm?.id;
    if (farmId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Animals')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animals', key: Key('animals_screen_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export CSV',
            onPressed: () async {
              final db = Provider.of<DatabaseService>(context, listen: false);
              final farmProv =
                  Provider.of<FarmProvider>(context, listen: false);
              final farmId = farmProv.selectedFarm?.id;
              if (farmId == null) return;
              final animals = await db.streamAnimals(farmId: farmId).first;
              // Apply current filters
              var filtered = animals;
              if (_search.isNotEmpty) {
                filtered = filtered
                    .where((a) =>
                        a.tagId.toLowerCase().contains(_search.toLowerCase()))
                    .toList();
              }
              if (_typeFilter != null) {
                filtered =
                    filtered.where((a) => a.type == _typeFilter).toList();
              }
              if (_statusFilter != null) {
                filtered =
                    filtered.where((a) => a.status == _statusFilter).toList();
              }
              await _exportToCSV(filtered);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Padding(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Search by Tag',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setState(() => _search = v.trim()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _typeFilter,
                      hint: const Text('Type'),
                      items: ['Sheep', 'Goat']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _typeFilter = v),
                    ),
                    const SizedBox(width: 12),
                    DropdownButton<String>(
                      value: _statusFilter,
                      hint: const Text('Status'),
                      items: ['Alive', 'Pregnant', 'Sold', 'Dead', 'Sick']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _statusFilter = v),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: StreamBuilder<List<Animal>>(
                    stream: db.streamAnimals(farmId: farmId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      var animals = snapshot.data!;
                      if (_search.isNotEmpty) {
                        animals = animals
                            .where((a) => a.tagId
                                .toLowerCase()
                                .contains(_search.toLowerCase()))
                            .toList();
                      }
                      if (_typeFilter != null) {
                        animals = animals
                            .where((a) => a.type == _typeFilter)
                            .toList();
                      }
                      if (_statusFilter != null) {
                        animals = animals
                            .where((a) => a.status == _statusFilter)
                            .toList();
                      }
                      if (animals.isEmpty) {
                        return Center(
                          child: Semantics(
                            label: 'No animals found',
                            child: Text('No animals found.',
                                style: Theme.of(context).textTheme.titleLarge),
                          ),
                        );
                      }
                      final isWide = constraints.maxWidth > 600;
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isWide ? 2 : 1,
                          crossAxisSpacing: isWide ? 32 : 16,
                          mainAxisSpacing: isWide ? 32 : 16,
                          childAspectRatio: isWide ? 2.2 : 2.8,
                        ),
                        itemCount: animals.length,
                        itemBuilder: (context, index) {
                          final animal = animals[index];
                          return Semantics(
                            label:
                                'Animal card: tag \\${animal.tagNumber}, type \\${animal.type}, breed \\${animal.breed}',
                            child: Card(
                              key: Key('animal_card_$index'),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.pushNamed(
                                    context, '/animalDetail',
                                    arguments: animal),
                                focusColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.2),
                                hoverColor: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 20),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 36,
                                        backgroundImage: (animal.photoUrls !=
                                                    null &&
                                                animal.photoUrls!.isNotEmpty)
                                            ? NetworkImage(
                                                animal.photoUrls!.first)
                                            : null,
                                        backgroundColor: (animal.photoUrls !=
                                                    null &&
                                                animal.photoUrls!.isNotEmpty)
                                            ? null
                                            : Color(int.parse(animal.tagColor)),
                                        child: (animal.photoUrls != null &&
                                                animal.photoUrls!.isNotEmpty)
                                            ? null
                                            : Text(animal.tagNumber.toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 28)),
                                      ),
                                      const SizedBox(width: 32),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '#${animal.tagNumber} - ${animal.type}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 24),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${animal.breed}, ${animal.birthDate.toLocal().toString().split(' ')[0]}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Tooltip(
                                        message: 'View animal details',
                                        child: Icon(Icons.arrow_forward_ios,
                                            size: 32, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Semantics(
        label: 'Add a new animal',
        child: FloatingActionButton.extended(
          key: const Key('add_animal_fab'),
          onPressed: () => Navigator.pushNamed(context, '/addAnimal'),
          icon: const Icon(Icons.add, size: 32),
          label: const Text('Add Animal', style: TextStyle(fontSize: 20)),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
