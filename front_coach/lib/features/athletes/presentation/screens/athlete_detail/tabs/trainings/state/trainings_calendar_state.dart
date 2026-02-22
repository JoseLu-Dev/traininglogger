import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:front_shared/front_shared.dart';

part 'trainings_calendar_state.freezed.dart';

@freezed
class TrainingsCalendarState with _$TrainingsCalendarState {
  const factory TrainingsCalendarState.initial() = _Initial;
  const factory TrainingsCalendarState.loading() = _Loading;
  const factory TrainingsCalendarState.loaded({
    required Map<String, TrainingPlan> plansByDate,
    required Map<String, TrainingSession> sessionsByDate,
    required DateTime focusedMonth,
    String? selectedDate,
  }) = _Loaded;
  const factory TrainingsCalendarState.error(String message) = _Error;
}
