import 'package:flutter/material.dart';

class BreedManagementScreen extends StatefulWidget {
  const BreedManagementScreen({super.key});

  @override
  State<BreedManagementScreen> createState() => _BreedManagementScreenState();
}

class _BreedManagementScreenState extends State<BreedManagementScreen> {
  final _breedController = TextEditingController();
  final List<String> _breeds = [
    'Damani',
    'Dimashqi',
    'Mixed',
  ];

  void _addBreed() {
    final breed = _breedController.text.trim();
    if (breed.isNotEmpty && !_breeds.contains(breed)) {
      setState(() {
        _breeds.add(breed);
        _breedController.clear();
      });
    }
  }

  void _removeBreed(String breed) {
    setState(() {
      _breeds.remove(breed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Breed Management')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Manage Breeds',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _breedController,
                    decoration: const InputDecoration(labelText: 'Add new breed'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _addBreed,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _breeds.length,
                itemBuilder: (context, i) {
                  final breed = _breeds[i];
                  return ListTile(
                    title: Text(breed),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeBreed(breed),
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
