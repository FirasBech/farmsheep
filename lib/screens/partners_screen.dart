import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/partner.dart';
import '../features/farm/presentation/providers/farm_notifier.dart';
import '../features/partner/presentation/providers/partner_provider.dart';
import '../core/utils/l10n_extension.dart';

class PartnersScreen extends ConsumerStatefulWidget {
  const PartnersScreen({super.key});

  @override
  ConsumerState<PartnersScreen> createState() => _PartnersScreenState();
}

class _PartnersScreenState extends ConsumerState<PartnersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farmId =
          ref.read(farmNotifierProvider).selectedFarm?.id;
      if (farmId != null) {
        ref.read(partnerNotifierProvider.notifier).loadPartners(farmId);
      }
    });
  }

  void _editPartner(Partner partner) {
    final l10n = context.l10n;
    String name = partner.name;
    String email = partner.email;
    String role = partner.role;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.editPartnerDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: name,
              decoration: InputDecoration(labelText: l10n.nameLabel),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: email,
              decoration: InputDecoration(labelText: l10n.emailLabel),
              onChanged: (v) => email = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: role,
              items: ['admin', 'partner']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => role = v ?? 'partner',
              decoration: InputDecoration(labelText: l10n.roleLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelButton),
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
              );
              await ref
                  .read(partnerNotifierProvider.notifier)
                  .updatePartner(updated);
              final farmId =
                  ref.read(farmNotifierProvider).selectedFarm?.id;
              if (farmId != null) {
                await ref
                    .read(partnerNotifierProvider.notifier)
                    .loadPartners(farmId);
              }
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.partnerUpdated)),
                );
              }
            },
            child: Text(l10n.saveButton),
          ),
        ],
      ),
    );
  }

  Future<void> _removePartner(Partner partner, String farmId) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removePartnerTitle),
        content: Text(l10n.removePartnerContent(partner.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancelButton)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.removeButton)),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(partnerNotifierProvider.notifier)
          .removePartner(partner.id, farmId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.partnerRemoved)),
        );
      }
    }
  }

  Color _roleColor(String role) {
    return role == 'admin' ? const Color(0xFF2E7D32) : const Color(0xFF558B2F);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final farmState = ref.watch(farmNotifierProvider);
    final selectedFarm = farmState.selectedFarm;
    if (selectedFarm == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.partnersTitle)),
        body: Center(child: Text(l10n.noFarmSelected)),
      );
    }
    final partnerState = ref.watch(partnerNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.partnersTitle)),
      body: partnerState.loading
          ? const Center(child: CircularProgressIndicator())
          : partnerState.partners.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF2E7D32).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.people_outline,
                            size: 64, color: Color(0xFF2E7D32)),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.noPartnersYet,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(
                          l10n.addPartnerToShare,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              )),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: partnerState.partners.length,
                  itemBuilder: (context, i) {
                    final partner = partnerState.partners[i];
                    final initials = partner.name.isNotEmpty
                        ? partner.name
                            .trim()
                            .split(' ')
                            .take(2)
                            .map((w) => w[0].toUpperCase())
                            .join()
                        : '?';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.15),
                              child: Text(
                                initials,
                                style: const TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(partner.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(partner.email,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                          fontSize: 13)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _roleColor(partner.role)
                                          .withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      partner.role,
                                      style: TextStyle(
                                          color: _roleColor(partner.role),
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
                                if (value == 'edit') {
                                  _editPartner(partner);
                                } else if (value == 'toggle_role') {
                                  final newRole = partner.role == 'admin'
                                      ? 'partner'
                                      : 'admin';
                                  final updated = Partner(
                                    id: partner.id,
                                    name: partner.name,
                                    email: partner.email,
                                    color: partner.color,
                                    farmIds: partner.farmIds,
                                    role: newRole,
                                  );
                                  final messenger =
                                      ScaffoldMessenger.of(context);
                                  await ref
                                      .read(partnerNotifierProvider.notifier)
                                      .updatePartner(updated);
                                  await ref
                                      .read(partnerNotifierProvider.notifier)
                                      .loadPartners(selectedFarm.id);
                                  if (mounted) {
                                    messenger.showSnackBar(SnackBar(
                                        content: Text(
                                            l10n.roleChangedTo(newRole))));
                                  }
                                } else if (value == 'remove') {
                                  await _removePartner(
                                      partner, selectedFarm.id);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      const Icon(Icons.edit_outlined, size: 18),
                                      const SizedBox(width: 8),
                                      Text(l10n.editMenuItem),
                                    ])),
                                PopupMenuItem(
                                    value: 'toggle_role',
                                    child: Row(children: [
                                      const Icon(Icons.swap_horiz,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Text(partner.role == 'admin'
                                          ? l10n.makePartnerMenuItem
                                          : l10n.makeAdminMenuItem),
                                    ])),
                                PopupMenuItem(
                                    value: 'remove',
                                    child: Row(children: [
                                      const Icon(Icons.person_remove_outlined,
                                          size: 18, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Text(l10n.removeButton,
                                          style: const TextStyle(color: Colors.red)),
                                    ])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/addPartner'),
        tooltip: l10n.addPartnerFabLabel,
        icon: const Icon(Icons.person_add),
        label: Text(l10n.addPartnerFabLabel),
      ),
    );
  }
}
