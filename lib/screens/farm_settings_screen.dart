import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/farm_provider.dart';
import '../models/farm.dart';

class FarmSettingsScreen extends StatefulWidget {
  const FarmSettingsScreen({super.key});

  @override
  State<FarmSettingsScreen> createState() => _FarmSettingsScreenState();
}

class _FarmSettingsScreenState extends State<FarmSettingsScreen> {
  final _notesController = TextEditingController();
  final _breedsController = TextEditingController();
  int? _farmColor;
  Map<String, bool> _partnerPermissions = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
    _notesController.text = farm?.notes ?? '';
    _breedsController.text = farm?.preferredBreeds.join(', ') ?? '';
    _farmColor = farm?.color;
    _partnerPermissions =
        Map<String, bool>.from(farm?.partnerPermissions ?? {});
  }

  @override
  Widget build(BuildContext context) {
    final farmProv = Provider.of<FarmProvider>(context);
    final farm = farmProv.selectedFarm;
    if (farm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Farm Settings')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Farm Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Farm: ${farm.name}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _breedsController,
                decoration: const InputDecoration(
                    labelText: 'Preferred Breeds (comma separated)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Farm Color:'),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      final color = await showDialog<int>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Pick Farm Color'),
                          content: SingleChildScrollView(
                            child: BlockPicker(
                              pickerColor: Color(_farmColor ?? 0xFF388E3C),
                              onColorChanged: (c) =>
                                  Navigator.pop(context, c.value),
                            ),
                          ),
                        ),
                      );
                      if (color != null) setState(() => _farmColor = color);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(_farmColor ?? 0xFF388E3C),
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Permissions:'),
              CheckboxListTile(
                title: const Text('Allow partners to add animals'),
                value: _partnerPermissions['add_animals'] ?? false,
                onChanged: (v) => setState(() {
                  _partnerPermissions['add_animals'] = v ?? false;
                }),
              ),
              CheckboxListTile(
                title: const Text('Allow partners to edit logs'),
                value: _partnerPermissions['edit_logs'] ?? false,
                onChanged: (v) => setState(() {
                  _partnerPermissions['edit_logs'] = v ?? false;
                }),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save Settings'),
                onPressed: () async {
                  final updated = Farm(
                    id: farm.id,
                    name: farm.name,
                    address: farm.address,
                    ownerId: farm.ownerId,
                    partnerIds: farm.partnerIds,
                    createdAt: farm.createdAt,
                    notes: _notesController.text,
                    archived: farm.archived,
                    preferredBreeds: _breedsController.text
                        .split(',')
                        .map((b) => b.trim())
                        .where((b) => b.isNotEmpty)
                        .toList(),
                    color: _farmColor ?? 0xFF388E3C,
                    partnerPermissions: _partnerPermissions,
                  );
                  await farmProv.updateFarm(updated);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Farm settings updated.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
