import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front_shared/front_shared.dart';

part 'exercise_list_state.freezed.dart';

@freezed
class ExerciseListState with _$ExerciseListState {
  const factory ExerciseListState.initial() = _Initial;
  const factory ExerciseListState.loading() = _Loading;
  const factory ExerciseListState.loaded({
    required List<Exercise> exercises,
    @Default(false) bool hasMore,
    @Default(0) int currentPage,
    String? searchQuery,
  }) = _Loaded;
  const factory ExerciseListState.error(String message) = _Error;
}
