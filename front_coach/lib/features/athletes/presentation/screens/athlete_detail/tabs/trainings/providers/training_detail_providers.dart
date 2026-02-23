import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../notifiers/training_detail_notifier.dart';
import '../state/training_detail_state.dart';

final trainingDetailProvider = StateNotifierProvider.autoDispose
    .family<TrainingDetailNotifier, TrainingDetailState, String>(
  (ref, athleteId) {
    final authState = ref.watch(authNotifierProvider);
    final coachId = authState.maybeWhen(
      authenticated: (id, email, role, coachId, isOffline) => id,
      orElse: () => '',
    );

    return TrainingDetailNotifier(
      exercisePlanRepo: ref.watch(exercisePlanRepositoryProvider),
      setPlanRepo: ref.watch(setPlanRepositoryProvider),
      epvRepo: ref.watch(exercisePlanVariantRepositoryProvider),
      sessionRepo: ref.watch(trainingSessionRepositoryProvider),
      exerciseSessionRepo: ref.watch(exerciseSessionRepositoryProvider),
      setSessionRepo: ref.watch(setSessionRepositoryProvider),
      esvRepo: ref.watch(exerciseSessionVariantRepositoryProvider),
      exerciseRepo: ref.watch(exerciseRepositoryProvider),
      variantRepo: ref.watch(variantRepositoryProvider),
      planRepo: ref.watch(trainingPlanRepositoryProvider),
      athleteId: athleteId,
      coachId: coachId,
    );
  },
);
