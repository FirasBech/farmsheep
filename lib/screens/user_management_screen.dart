import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_notifier.dart';
import '../core/utils/l10n_extension.dart';

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends ConsumerState<UserManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).loadUsers();
    });
  }

  Future<void> _resetPassword(String email) async {
    await ref.read(authNotifierProvider.notifier).sendPasswordResetEmail(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.passwordResetEmailSent)),
    );
  }

  Future<void> _updateRole(String uid, String newRole) async {
    await ref.read(authNotifierProvider.notifier).updateUserRole(uid, newRole);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.roleUpdatedTo(newRole))),
    );
  }

  Color _roleColor(String? role) {
    return role == 'admin'
        ? const Color(0xFF2E7D32)
        : const Color(0xFF558B2F);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authNotifierProvider);
    final loading = authState.usersLoading;
    final users = authState.users;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userManagementTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshTooltip,
            onPressed: () =>
                ref.read(authNotifierProvider.notifier).loadUsers(),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.people_outline,
                            size: 64, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.noUsersFound,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final user = users[i];
                    final name = user['name'] as String? ??
                        user['displayName'] as String? ??
                        '';
                    final email = user['email'] as String? ?? '';
                    final role = user['role'] as String? ?? 'partner';
                    final uid = user['uid'] as String? ?? '';
                    final initials = name.isNotEmpty
                        ? name
                            .trim()
                            .split(' ')
                            .take(2)
                            .map((w) => w[0].toUpperCase())
                            .join()
                        : (email.isNotEmpty
                            ? email[0].toUpperCase()
                            : '?');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  _roleColor(role).withValues(alpha: 0.15),
                              child: Text(
                                initials,
                                style: TextStyle(
                                    color: _roleColor(role),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (name.isNotEmpty)
                                    Text(name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  Text(email,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6))),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _roleColor(role)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                          color: _roleColor(role),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'make_admin') {
                                  await _updateRole(uid, 'admin');
                                } else if (value == 'make_partner') {
                                  await _updateRole(uid, 'partner');
                                } else if (value == 'reset_password') {
                                  await _resetPassword(email);
                                }
                              },
                              itemBuilder: (_) => [
                                if (role != 'admin')
                                  PopupMenuItem(
                                      value: 'make_admin',
                                      child: Row(children: [
                                        const Icon(
                                            Icons
                                                .admin_panel_settings_outlined,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Text(l10n.makeAdminMenuItem),
                                      ])),
                                if (role != 'partner')
                                  PopupMenuItem(
                                      value: 'make_partner',
                                      child: Row(children: [
                                        const Icon(Icons.person_outline, size: 18),
                                        const SizedBox(width: 8),
                                        Text(l10n.makePartnerMenuItem),
                                      ])),
                                PopupMenuItem(
                                    value: 'reset_password',
                                    child: Row(children: [
                                      const Icon(Icons.lock_reset_outlined,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(l10n.resetPasswordMenuItem),
                                    ])),
                              ],
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
