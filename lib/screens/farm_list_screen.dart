import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';

class FarmListScreen extends StatelessWidget {
  const FarmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farmProv = Provider.of<FarmProvider>(context);
    final farms = farmProv.farms;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Farms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.unarchive),
            tooltip: 'View Archived Farms',
            onPressed: () async {
              final archived = farmProv.archivedFarms;
              if (archived.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No archived farms.')),
                );
                return;
              }
              await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Archived Farms'),
                  content: SizedBox(
                    width: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: archived.length,
                      itemBuilder: (context, i) {
                        final farm = archived[i];
                        return ListTile(
                          title: Text(farm.name),
                          subtitle: Text(farm.address),
                          trailing: IconButton(
                            icon: const Icon(Icons.restore),
                            tooltip: 'Restore',
                            onPressed: () async {
                              await farmProv.updateFarm(
                                Farm(
                                  id: farm.id,
                                  name: farm.name,
                                  address: farm.address,
                                  ownerId: farm.ownerId,
                                  partnerIds: farm.partnerIds,
                                  createdAt: farm.createdAt,
                                  notes: farm.notes,
                                  archived: false,
                                ),
                              );
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Farm restored.')),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: farms.isEmpty
          ? const Center(child: Text('No farms found. Add your first farm!'))
          : ListView.builder(
              itemCount: farms.length,
              itemBuilder: (context, i) {
                final farm = farms[i];
                return Card(
                  child: ListTile(
                    title: Text(farm.name),
                    subtitle: Text(farm.address),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (farmProv.selectedFarm?.id == farm.id)
                          const Icon(Icons.check_circle, color: Colors.green),
                        IconButton(
                          icon: const Icon(Icons.archive),
                          tooltip: 'Archive Farm',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Archive Farm'),
                                content: const Text(
                                    'Are you sure you want to archive this farm? You can restore it later.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Archive'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await farmProv.archiveFarm(farm.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Farm archived.')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete Farm',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Farm'),
                                content: const Text(
                                    'Are you sure you want to delete this farm? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await farmProv.deleteFarm(farm.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Farm deleted.')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      farmProv.selectFarm(farm);
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final nameController = TextEditingController();
          final addressController = TextEditingController();
          await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Add Farm'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Farm Name'),
                  ),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: 'Address'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final address = addressController.text.trim();
                    if (name.isEmpty || address.isEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Farm name and address are required.')),
                      );
                      return;
                    }
                    try {
                      await farmProv.addFarm(name, address);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Farm added!')),
                      );
                    } catch (e) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding farm: $e')),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        tooltip: 'Add Farm',
        child: const Icon(Icons.add),
      ),
    );
  }
}
