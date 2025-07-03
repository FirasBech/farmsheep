import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/partner.dart';
import '../providers/farm_provider.dart';
import '../services/database_service.dart';

class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  void _editPartner(BuildContext context, Partner partner) {
    showDialog(
      context: context,
      builder: (context) {
        String name = partner.name;
        String email = partner.email;
        String role = partner.role;
        return AlertDialog(
          title: const Text('Edit Partner'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (v) => name = v,
              ),
              TextFormField(
                initialValue: email,
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (v) => email = v,
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: ['admin', 'partner']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => role = v ?? 'partner',
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = Partner(
                  id: partner.id,
                  name: name,
                  email: email,
                  color: partner.color,
                  farmIds: partner.farmIds,
                  role: role,
                  farmId: partner.farmId,
                );
                await DatabaseService().updatePartner(updated);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partner updated.')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _removePartner(
      BuildContext context, Partner partner, String farmId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Partner'),
        content: Text('Remove ${partner.name} from this farm?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService().removePartnerFromFarm(partner.id, farmId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partner removed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProv = Provider.of<FarmProvider>(context);
    final selectedFarm = farmProv.selectedFarm;
    if (selectedFarm == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Partners')),
        body: const Center(child: Text('No farm selected.')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Partners')),
      body: FutureBuilder<List<Partner>>(
        future: DatabaseService().getPartnersForFarm(selectedFarm.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No partners found for this farm.'));
          }
          final partners = snapshot.data!;
          return ListView.builder(
            itemCount: partners.length,
            itemBuilder: (context, i) {
              final partner = partners[i];
              return ListTile(
                title: Text(partner.name),
                subtitle: Text(partner.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: partner.role,
                      items: ['admin', 'partner']
                          .map((role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ))
                          .toList(),
                      onChanged: (role) async {
                        final updated = Partner(
                          id: partner.id,
                          name: partner.name,
                          email: partner.email,
                          color: partner.color,
                          farmIds: partner.farmIds,
                          role: role ?? 'partner',
                          farmId: partner.farmId,
                        );
                        await DatabaseService().updatePartner(updated);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Role updated.')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _editPartner(context, partner),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      tooltip: 'Remove',
                      onPressed: () =>
                          _removePartner(context, partner, selectedFarm.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addPartner'),
        tooltip: 'Add Partner',
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
