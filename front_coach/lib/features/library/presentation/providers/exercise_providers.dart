import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../notifiers/exercise_list_notifier.dart';
import '../notifiers/exercise_form_notifier.dart';
import '../state/exercise_list_state.dart';
import '../state/exercise_form_state.dart';

/// Provider for exercise list state management
final exerciseListNotifierProvider =
    StateNotifierProvider.autoDispose<ExerciseListNotifier, ExerciseListState>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final coachId = authState.maybeWhen(
    authenticated: (id, email, role, authCoachId, isOffline) =>
        role == 'COACH' ? id : authCoachId ?? '',
    orElse: () => '',
  );

  return ExerciseListNotifier(
    ref.watch(exerciseRepositoryProvider),
    coachId,
  );
});

/// Provider for exercise form state management
/// The exerciseId parameter is null for create mode, non-null for edit mode
final exerciseFormNotifierProvider = StateNotifierProvider.autoDispose.family<
    ExerciseFormNotifier, ExerciseFormState, String?>((ref, exerciseId) {
  final authState = ref.watch(authNotifierProvider);
  final coachId = authState.maybeWhen(
    authenticated: (id, email, role, authCoachId, isOffline) =>
        role == 'COACH' ? id : authCoachId ?? '',
    orElse: () => '',
  );

  return ExerciseFormNotifier(
    ref.watch(exerciseRepositoryProvider),
    coachId,
    exerciseId,
  );
});
