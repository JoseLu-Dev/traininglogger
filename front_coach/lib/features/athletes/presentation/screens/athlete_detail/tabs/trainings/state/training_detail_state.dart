import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front_shared/front_shared.dart';
import '../models/exercise_detail_data.dart';

part 'training_detail_state.freezed.dart';

@freezed
class TrainingDetailState with _$TrainingDetailState {
  const factory TrainingDetailState.empty() = _Empty;
  const factory TrainingDetailState.loading() = _Loading;
  const factory TrainingDetailState.editionMode({
    required TrainingPlan plan,
    required List<ExerciseDetailData> exercises,
  }) = _EditionMode;
  const factory TrainingDetailState.seeMode({
    required TrainingPlan plan,
    TrainingSession? session,
    required List<ExerciseDetailData> exercises,
  }) = _SeeMode;
  const factory TrainingDetailState.error(String message) = _Error;
}
