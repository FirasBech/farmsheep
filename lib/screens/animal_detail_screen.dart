import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/animal.dart';
import 'edit_animal_screen.dart';
import '../services/database_service.dart';
import '../providers/farm_provider.dart';

class AnimalDetailScreen extends StatefulWidget {
  const AnimalDetailScreen({super.key});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late Animal animal;
  bool _loading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animal = ModalRoute.of(context)!.settings.arguments as Animal;
  }

  Future<void> _refreshAnimal() async {
    setState(() => _loading = true);
    final db = Provider.of<DatabaseService>(context, listen: false);
    // Try to fetch the latest animal by id
    final farmProv = Provider.of<FarmProvider>(context, listen: false);
    final farmId = farmProv.selectedFarm?.id ?? '';
    final animals = await db.streamAnimals(farmId: farmId).first;
    final updated =
        animals.firstWhere((a) => a.id == animal.id, orElse: () => animal);
    setState(() {
      animal = updated;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Details', key: Key('animal_details_screen_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit animal details',
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAnimalScreen(animal: animal),
                ),
              );
              if (updated == true) {
                // Pop this detail screen and re-push with updated animal from provider
                final db = Provider.of<DatabaseService>(context, listen: false);
                final farmProv =
                    Provider.of<FarmProvider>(context, listen: false);
                final farmId = farmProv.selectedFarm?.id ?? '';
                final animals = await db.streamAnimals(farmId: farmId).first;
                final refreshed = animals.firstWhere((a) => a.id == animal.id,
                    orElse: () => animal);
                Navigator.pop(context);
                await Future.delayed(const Duration(milliseconds: 100));
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AnimalDetailScreen(),
                    settings: RouteSettings(arguments: refreshed),
                  ),
                );
              }
            },
          ),
          IconButton(
            key: const Key('delete_animal_button'),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete animal',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Animal'),
                  content: const Text('Are you sure you want to delete this animal?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                final db = Provider.of<DatabaseService>(context, listen: false);
                await db.deleteAnimal(animal.id);
                Navigator.pop(context, 'deleted');
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Padding(
                  padding: EdgeInsets.all(isWide ? 32 : 16),
                  child: Semantics(
                    label: 'Animal details for tag \\${animal.tagNumber}',
                    child: FocusTraversalGroup(
                      child: ListView(
                        children: [
                          if (animal.photoUrls != null &&
                              animal.photoUrls!.isNotEmpty) ...[
                            SizedBox(
                              height: isWide ? 280 : 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: animal.photoUrls!.length,
                                itemBuilder: (context, i) {
                                  final url = animal.photoUrls![i];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: Semantics(
                                      label: 'Animal photo ${i + 1}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(url,
                                            fit: BoxFit.cover,
                                            width: isWide ? 280 : 200),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: isWide ? 24 : 16),
                          ],
                          Card(
                            child: ListTile(
                              leading: Tooltip(
                                message: 'Ear tag',
                                child: Icon(Icons.label,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              title: const Text('Ear Tag',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '#${animal.tagNumber} (${animal.tagColor})',
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          SizedBox(height: isWide ? 16 : 8),
                          Card(
                            child: ListTile(
                              leading: Tooltip(
                                message: 'Animal type',
                                child: Icon(Icons.pets,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              title: const Text('Type',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(animal.type,
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          SizedBox(height: isWide ? 16 : 8),
                          Card(
                            child: ListTile(
                              leading: Tooltip(
                                message: 'Breed',
                                child: Icon(Icons.grass,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              title: const Text('Breed',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(animal.breed,
                                  key: const Key('animal_breed_text'),
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          SizedBox(height: isWide ? 16 : 8),
                          Card(
                            child: ListTile(
                              leading: Tooltip(
                                message: 'Birth date',
                                child: Icon(Icons.cake,
                                    size: 40,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              title: const Text('Birth Date',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  animal.birthDate
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  style: const TextStyle(fontSize: 18)),
                            ),
                          ),
                          SizedBox(height: isWide ? 24 : 16),
                          Semantics(
                            label: 'Pregnancy history',
                            child: Text('Pregnancy History',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22)),
                          ),
                          ...animal.pregnancyHistory.map((e) => ListTile(
                                leading: Tooltip(
                                  message: 'Pregnancy month',
                                  child: Icon(Icons.pregnant_woman,
                                      size: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                title: Text('Month: \\${e['month']}',
                                    style: const TextStyle(fontSize: 18)),
                                subtitle: Text('Count: \\${e['count']}',
                                    style: const TextStyle(fontSize: 16)),
                              )),
                          SizedBox(height: isWide ? 24 : 16),
                          Semantics(
                            label: 'Birth log',
                            child: Text('Birth Log',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22)),
                          ),
                          ...animal.birthLog.map((e) => ListTile(
                                leading: Tooltip(
                                  message: 'Birth event',
                                  child: Icon(Icons.child_care,
                                      size: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                title: Text(
                                    e['date']
                                        .toDate()
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                    style: const TextStyle(fontSize: 18)),
                                subtitle: Text('Babies: \\${e['babies']}',
                                    style: const TextStyle(fontSize: 16)),
                              )),
                          SizedBox(height: isWide ? 24 : 16),
                          Semantics(
                            label: 'Health logs',
                            child: Text('Health Logs',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22)),
                          ),
                          ...animal.healthLogs.map((e) => ListTile(
                                leading: Tooltip(
                                  message: 'Health event',
                                  child: Icon(Icons.healing,
                                      size: 32,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                ),
                                title: Text(
                                    e['date']
                                        .toDate()
                                        .toLocal()
                                        .toString()
                                        .split(' ')[0],
                                    style: const TextStyle(fontSize: 18)),
                                subtitle: Text(
                                    '${e['type']}: ${e['notes'] ?? ''}',
                                    style: const TextStyle(fontSize: 16)),
                              )),
                          SizedBox(height: isWide ? 24 : 16),
                          if (animal.saleInfo != null) ...[
                            Semantics(
                              label: 'Sale info',
                              child: Text('Sale Info',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22)),
                            ),
                            ListTile(
                              leading: Tooltip(
                                message: 'Sold to',
                                child: Icon(Icons.sell,
                                    size: 32,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              title: const Text('Sold To',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(animal.saleInfo?['buyer'] ?? '',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                            ListTile(
                              leading: Tooltip(
                                message: 'Sale date',
                                child: Icon(Icons.event,
                                    size: 32,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              title: const Text('Sale Date',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                animal.saleInfo?['date'] != null
                                    ? (animal.saleInfo!['date'] is Timestamp
                                        ? (animal.saleInfo!['date']
                                                as Timestamp)
                                            .toDate()
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0]
                                        : animal.saleInfo!['date'].toString())
                                    : '',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            ListTile(
                              leading: Tooltip(
                                message: 'Sale price',
                                child: Icon(Icons.attach_money,
                                    size: 32,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              title: const Text('Price',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  animal.saleInfo?['price']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
