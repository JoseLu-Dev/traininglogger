import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../state/exercise_form_state.dart';

class ExerciseFormNotifier extends StateNotifier<ExerciseFormState> {
  final ExerciseRepository _repository;
  final String _coachId;
  final String? _exerciseId;

  ExerciseFormNotifier(
    this._repository,
    this._coachId,
    this._exerciseId,
  ) : super(const ExerciseFormState.initial()) {
    if (_exerciseId != null) {
      _loadExercise(_exerciseId);
    } else {
      state = const ExerciseFormState.loaded();
    }
  }

  Future<void> _loadExercise(String id) async {
    try {
      state = const ExerciseFormState.loading();
      final exercise = await _repository.findById(id);

      if (exercise == null) {
        state = const ExerciseFormState.error('Exercise not found');
        return;
      }

      state = ExerciseFormState.loaded(exercise: exercise);
    } catch (e) {
      state = ExerciseFormState.error('Failed to load exercise: $e');
    }
  }

  Future<void> createExercise(
    String name,
    String? category,
    String? description,
  ) async {
    try {
      state = const ExerciseFormState.saving();

      final exercise = Exercise.create(
        coachId: _coachId,
        name: name,
        category: category,
        description: description,
      );

      await _repository.create(exercise);

      state = const ExerciseFormState.saved();
    } catch (e) {
      state = ExerciseFormState.error('Failed to create exercise: $e');
    }
  }

  Future<void> updateExercise(
    String id,
    String name,
    String? category,
    String? description,
  ) async {
    try {
      state = const ExerciseFormState.saving();

      final currentExercise = await _repository.findById(id);
      if (currentExercise == null) {
        state = const ExerciseFormState.error('Exercise not found');
        return;
      }

      final updatedExercise = currentExercise.copyWith(
        name: name,
        category: category,
        description: description,
      ).markDirty();

      await _repository.update(updatedExercise);

      state = const ExerciseFormState.saved();
    } catch (e) {
      state = ExerciseFormState.error('Failed to update exercise: $e');
    }
  }
}
