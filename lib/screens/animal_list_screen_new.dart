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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'pregnant':
        return Colors.blue;
      case 'sold':
        return Colors.orange;
      case 'dead':
        return Colors.red;
      case 'sick':
        return Colors.amber;
      default:
        return Colors.grey;
    }
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Animals', key: Key('animals_screen_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export CSV',
            onPressed: () async {
              final animals = await db.streamAnimals(farmId: farmId).first;
              var filtered = animals;
              if (_search.isNotEmpty) {
                filtered = filtered
                    .where((a) =>
                        a.tagId.toLowerCase().contains(_search.toLowerCase()))
                    .toList();
              }
              if (_typeFilter != null) {
                filtered = filtered.where((a) => a.type == _typeFilter).toList();
              }
              if (_statusFilter != null) {
                filtered = filtered.where((a) => a.status == _statusFilter).toList();
              }
              await _exportToCSV(filtered);
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Animal',
            onPressed: () => Navigator.pushNamed(context, '/addAnimal'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search and filter section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search & Filter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Search by Tag ID',
                      hintText: 'Enter tag number...',
                      prefixIcon: const Icon(Icons.search_outlined),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _search = ''),
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() => _search = v.trim()),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _typeFilter,
                            hint: const Text('Filter by Type'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Types'),
                              ),
                              ...['Sheep', 'Goat']
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                            ],
                            onChanged: (v) => setState(() => _typeFilter = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            hint: const Text('Filter by Status'),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Statuses'),
                              ),
                              ...['Alive', 'Pregnant', 'Sold', 'Dead', 'Sick']
                                  .map((status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ))
                                  .toList(),
                            ],
                            onChanged: (v) => setState(() => _statusFilter = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.pets_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No animals found',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _search.isNotEmpty || _typeFilter != null || _statusFilter != null
                                ? 'Try adjusting your search filters'
                                : 'Add your first animal to get started!',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      return Container(
                        key: Key('animal_card_$index'),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pushNamed(
                                context, '/animalDetail',
                                arguments: animal),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: (animal.photoUrls != null && animal.photoUrls!.isNotEmpty)
                                          ? null
                                          : Color(int.parse(animal.tagColor)),
                                      image: (animal.photoUrls != null && animal.photoUrls!.isNotEmpty)
                                          ? DecorationImage(
                                              image: NetworkImage(animal.photoUrls!.first),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: (animal.photoUrls == null || animal.photoUrls!.isEmpty)
                                        ? Center(
                                            child: Text(
                                              animal.tagNumber.toString(),
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '#${animal.tagNumber} - ${animal.type}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          animal.breed,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: _getStatusColor(animal.status).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                animal.status,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: _getStatusColor(animal.status),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Born: ${animal.birthDate.year}/${animal.birthDate.month}/${animal.birthDate.day}',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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
      ),
    );
  }
}
