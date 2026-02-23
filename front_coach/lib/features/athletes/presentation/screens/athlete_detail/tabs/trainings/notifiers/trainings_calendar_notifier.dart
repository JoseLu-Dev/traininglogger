import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../state/trainings_calendar_state.dart';

class TrainingsCalendarNotifier extends StateNotifier<TrainingsCalendarState> {
  final TrainingPlanRepository _planRepo;
  final TrainingSessionRepository _sessionRepo;
  final String _athleteId;

  DateTime _focusedMonth = DateTime.now();

  TrainingsCalendarNotifier(this._planRepo, this._sessionRepo, this._athleteId)
      : super(const TrainingsCalendarState.initial()) {
    _loadMonth(DateTime.now(), initial: true);
  }

  String _dateKey(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  Future<void> _loadMonth(
    DateTime month, {
    bool initial = false,
    String? selectAfter,
    bool clearSelection = false,
  }) async {
    _focusedMonth = month;
    try {
      if (initial) state = const TrainingsCalendarState.loading();

      // Load a 3-month window: prev, current, next for smooth navigation
      final start = DateTime(month.year, month.month - 1, 1);
      final end = DateTime(month.year, month.month + 2, 0); // last day of next month

      final plans = await _planRepo.findByAthleteBetweenDates(
        _athleteId,
        _dateKey(start),
        _dateKey(end),
      );
      final sessions = await _sessionRepo.findByAthleteId(_athleteId);

      final plansByDate = <String, TrainingPlan>{};
      for (final plan in plans) {
        plansByDate[plan.date] = plan;
      }

      final sessionsByDate = <String, TrainingSession>{};
      for (final session in sessions) {
        sessionsByDate[session.sessionDate] = session;
      }

      // Use selectAfter if provided, otherwise preserve the current selection
      final current = state;
      final prevSelected = current.maybeWhen(loaded: (_, _, _, sel) => sel, orElse: () => null);

      state = TrainingsCalendarState.loaded(
        plansByDate: plansByDate,
        sessionsByDate: sessionsByDate,
        focusedMonth: _focusedMonth,
        selectedDate: clearSelection ? null : (selectAfter ?? prevSelected),
      );
    } catch (e) {
      state = TrainingsCalendarState.error('Failed to load trainings: $e');
    }
  }

  Future<void> loadMonth(DateTime month) => _loadMonth(month);

  Future<void> addTraining(String date, String name) async {
    try {
      final plan = TrainingPlan.create(
        athleteId: _athleteId,
        name: name,
        date: date,
      );
      await _planRepo.create(plan);
      await _loadMonth(_focusedMonth, selectAfter: date);
    } catch (e) {
      state = TrainingsCalendarState.error('Failed to add training: $e');
    }
  }

  Future<void> deleteTraining(String planId) async {
    try {
      await _planRepo.delete(planId);
      await _loadMonth(_focusedMonth, clearSelection: true);
    } catch (e) {
      state = TrainingsCalendarState.error('Failed to delete training: $e');
    }
  }

  Future<void> moveTraining(TrainingPlan plan, String newDate) async {
    if (plan.date == newDate) return;
    try {
      await _planRepo.update(plan.copyWith(
        date: newDate,
        isDirty: true,
        updatedAt: DateTime.now(),
      ));
      await _loadMonth(_focusedMonth);
    } catch (e) {
      state = TrainingsCalendarState.error('Failed to move training: $e');
    }
  }

  void selectDate(String date) {
    state.maybeWhen(
      loaded: (plansByDate, sessionsByDate, focusedMonth, _) {
        state = TrainingsCalendarState.loaded(
          plansByDate: plansByDate,
          sessionsByDate: sessionsByDate,
          focusedMonth: focusedMonth,
          selectedDate: date,
        );
      },
      orElse: () {},
    );
  }
}
