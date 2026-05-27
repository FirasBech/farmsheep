import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/partner.dart';
import '../../data/repositories/partner_repository_impl.dart';
import '../../domain/repositories/partner_repository.dart';

// ── Repository provider ────────────────────────────────────────────────────

final partnerRepositoryProvider = Provider<PartnerRepository>((ref) {
  return PartnerRepositoryImpl();
});

// ── State ──────────────────────────────────────────────────────────────────

class PartnerState {
  final List<Partner> partners;
  final bool loading;

  const PartnerState({this.partners = const [], this.loading = false});

  PartnerState copyWith({List<Partner>? partners, bool? loading}) =>
      PartnerState(
        partners: partners ?? this.partners,
        loading: loading ?? this.loading,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────

class PartnerNotifier extends Notifier<PartnerState> {
  @override
  PartnerState build() => const PartnerState();

  PartnerRepository get _repo => ref.read(partnerRepositoryProvider);

  Future<void> loadPartners(String farmId) async {
    state = state.copyWith(loading: true);
    final partners = await _repo.getPartners(farmId);
    state = state.copyWith(partners: partners, loading: false);
  }

  Future<void> updatePartner(Partner partner) async {
    await _repo.updatePartner(partner);
  }

  Future<void> removePartner(String partnerId, String farmId) async {
    await _repo.removePartner(partnerId, farmId);
    state = state.copyWith(
      partners: state.partners.where((p) => p.id != partnerId).toList(),
    );
  }
}

final partnerNotifierProvider =
    NotifierProvider<PartnerNotifier, PartnerState>(PartnerNotifier.new);
