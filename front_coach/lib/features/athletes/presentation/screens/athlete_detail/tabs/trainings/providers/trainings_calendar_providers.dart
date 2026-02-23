import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../notifiers/trainings_calendar_notifier.dart';
import '../state/trainings_calendar_state.dart';

final trainingsCalendarProvider = StateNotifierProvider.autoDispose
    .family<TrainingsCalendarNotifier, TrainingsCalendarState, String>(
  (ref, athleteId) => TrainingsCalendarNotifier(
    ref.watch(trainingPlanRepositoryProvider),
    ref.watch(trainingSessionRepositoryProvider),
    athleteId,
  ),
);
