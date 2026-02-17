import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front_shared/front_shared.dart';

part 'exercise_form_state.freezed.dart';

@freezed
class ExerciseFormState with _$ExerciseFormState {
  const factory ExerciseFormState.initial() = _Initial;
  const factory ExerciseFormState.loading() = _Loading;
  const factory ExerciseFormState.loaded({Exercise? exercise}) = _Loaded;
  const factory ExerciseFormState.saving() = _Saving;
  const factory ExerciseFormState.saved() = _Saved;
  const factory ExerciseFormState.error(String message) = _Error;
}
