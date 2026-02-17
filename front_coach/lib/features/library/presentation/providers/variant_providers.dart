import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../notifiers/variant_list_notifier.dart';
import '../notifiers/variant_form_notifier.dart';
import '../state/variant_list_state.dart';
import '../state/variant_form_state.dart';

/// Provider for variant list state management
final variantListNotifierProvider =
    StateNotifierProvider.autoDispose<VariantListNotifier, VariantListState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final coachId = authState.maybeWhen(
    authenticated: (id, email, role, authCoachId, isOffline) =>
        role == 'COACH' ? id : authCoachId ?? '',
    orElse: () => '',
  );

  return VariantListNotifier(
    ref.watch(variantRepositoryProvider),
    coachId,
  );
});

/// Provider for variant form state management
/// The variantId parameter is null for create mode, non-null for edit mode
final variantFormNotifierProvider = StateNotifierProvider.autoDispose.family<
    VariantFormNotifier, VariantFormState, String?>((ref, variantId) {
  final authState = ref.watch(authNotifierProvider);
  final coachId = authState.maybeWhen(
    authenticated: (id, email, role, authCoachId, isOffline) =>
        role == 'COACH' ? id : authCoachId ?? '',
    orElse: () => '',
  );

  return VariantFormNotifier(
    ref.watch(variantRepositoryProvider),
    coachId,
    variantId,
  );
});
