import 'package:flutter/material.dart';

class AdminOverrideScreen extends StatelessWidget {
  const AdminOverrideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder: In a real app, fetch animals/logs from Firestore and allow admin override
    final items = [
      {'type': 'animal', 'id': 'A001', 'desc': 'Sheep #1, Alive'},
      {'type': 'log', 'id': 'L001', 'desc': 'Manual log: Deworming'},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Record Override')),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('${item['type']} #${item['id']}'),
              subtitle: Text(item['desc'] ?? ''),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () {
                  // TODO: Open edit dialog, log override action
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
