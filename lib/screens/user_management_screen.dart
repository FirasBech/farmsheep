import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final usersSnap =
        await FirebaseFirestore.instance.collection('users').get();
    setState(() {
      _users = usersSnap.docs.map((d) => d.data()).toList();
      _loading = false;
    });
  }

  Future<void> _resetPassword(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Password reset email sent.')));
  }

  Future<void> _updateRole(String uid, String newRole) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'role': newRole});
    await _fetchUsers();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Role updated.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, i) {
                final user = _users[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(user['displayName'] ?? user['email'] ?? ''),
                    subtitle: Text(user['email'] ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: user['role'] ?? 'partner',
                          items: ['admin', 'partner']
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (role) => _updateRole(user['uid'], role!),
                        ),
                        IconButton(
                          icon: const Icon(Icons.lock_reset),
                          tooltip: 'Reset Password',
                          onPressed: () => _resetPassword(user['email']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
