import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';
import '../models/exercise_detail_data.dart';
import '../state/training_detail_state.dart';

// ── Week copy result ───────────────────────────────────────────────────────

enum CopyWeekStatus { success, conflict, empty }

class CopyWeekResult {
  final CopyWeekStatus status;
  final List<String> conflictingDates;
  const CopyWeekResult._(this.status, [this.conflictingDates = const []]);
  static const success = CopyWeekResult._(CopyWeekStatus.success);
  static const empty = CopyWeekResult._(CopyWeekStatus.empty);
  factory CopyWeekResult.conflict(List<String> dates) =>
      CopyWeekResult._(CopyWeekStatus.conflict, dates);
}

class TrainingDetailNotifier extends StateNotifier<TrainingDetailState> {
  final ExercisePlanRepository _exercisePlanRepo;
  final SetPlanRepository _setPlanRepo;
  final ExercisePlanVariantRepository _epvRepo;
  final TrainingSessionRepository _sessionRepo;
  final ExerciseSessionRepository _exerciseSessionRepo;
  final SetSessionRepository _setSessionRepo;
  final ExerciseSessionVariantRepository _esvRepo;
  final ExerciseRepository _exerciseRepo;
  final VariantRepository _variantRepo;
  final TrainingPlanRepository _planRepo;
  final String _athleteId;
  final String _coachId;

  TrainingDetailNotifier({
    required ExercisePlanRepository exercisePlanRepo,
    required SetPlanRepository setPlanRepo,
    required ExercisePlanVariantRepository epvRepo,
    required TrainingSessionRepository sessionRepo,
    required ExerciseSessionRepository exerciseSessionRepo,
    required SetSessionRepository setSessionRepo,
    required ExerciseSessionVariantRepository esvRepo,
    required ExerciseRepository exerciseRepo,
    required VariantRepository variantRepo,
    required TrainingPlanRepository planRepo,
    required String athleteId,
    required String coachId,
  })  : _exercisePlanRepo = exercisePlanRepo,
        _setPlanRepo = setPlanRepo,
        _epvRepo = epvRepo,
        _sessionRepo = sessionRepo,
        _exerciseSessionRepo = exerciseSessionRepo,
        _setSessionRepo = setSessionRepo,
        _esvRepo = esvRepo,
        _exerciseRepo = exerciseRepo,
        _variantRepo = variantRepo,
        _planRepo = planRepo,
        _athleteId = athleteId,
        _coachId = coachId,
        super(const TrainingDetailState.empty());

  // ── Public API ────────────────────────────────────────────────────────────

  void reset() {
    state = const TrainingDetailState.empty();
  }

  Future<void> loadDate(String dateKey, TrainingPlan plan) async {
    state = const TrainingDetailState.loading();
    try {
      if (plan.isLocked) {
        final sessions = await _sessionRepo.findByTrainingPlanId(plan.id);
        final session = sessions.isNotEmpty ? sessions.first : null;
        final exercises = await _loadExercisesForPlan(plan.id, session: session);
        state = TrainingDetailState.seeMode(
          plan: plan,
          session: session,
          exercises: exercises,
        );
      } else {
        final exercises = await _loadExercisesForPlan(plan.id);
        state = TrainingDetailState.editionMode(
          plan: plan,
          exercises: exercises,
        );
      }
    } catch (e) {
      state = TrainingDetailState.error('Failed to load training: $e');
    }
  }

  Future<void> renamePlan(String newName) async {
    final plan = _currentPlan;
    if (plan == null) return;
    try {
      final updated = plan.copyWith(
        name: newName,
        isDirty: true,
        updatedAt: DateTime.now(),
      );
      await _planRepo.update(updated);
      _mutatePlan(updated);
    } catch (_) {}
  }

  Future<void> addExercise(Exercise ex, List<Variant> variants) async {
    final exercises = _currentExercises;
    final plan = _currentPlan;
    if (exercises == null || plan == null) return;

    final ep = ExercisePlan.create(
      athleteId: _athleteId,
      trainingPlanId: plan.id,
      exerciseId: ex.id,
      orderIndex: exercises.length,
    );
    await _exercisePlanRepo.create(ep);

    for (final v in variants) {
      await _epvRepo.create(ExercisePlanVariant.create(
        athleteId: _athleteId,
        exercisePlanId: ep.id,
        variantId: v.id,
      ));
    }

    _updateExercises([
      ...exercises,
      ExerciseDetailData(
        plan: ep,
        exercise: ex,
        variants: variants,
        sets: [],
      ),
    ]);
  }

  Future<void> deleteExercise(String exercisePlanId) async {
    await _exercisePlanRepo.delete(exercisePlanId);
    final exercises = _currentExercises;
    if (exercises == null) return;
    _updateExercises(
      exercises.where((e) => e.plan.id != exercisePlanId).toList(),
    );
  }

  Future<void> reorderExercise(int oldIdx, int newIdx) async {
    final exercises = _currentExercises;
    if (exercises == null) return;

    if (newIdx > oldIdx) newIdx -= 1;
    final reordered = List<ExerciseDetailData>.from(exercises);
    final item = reordered.removeAt(oldIdx);
    reordered.insert(newIdx, item);

    for (int i = 0; i < reordered.length; i++) {
      if (reordered[i].plan.orderIndex != i) {
        final updated = reordered[i].plan.copyWith(
          orderIndex: i,
          isDirty: true,
          updatedAt: DateTime.now(),
        );
        await _exercisePlanRepo.update(updated);
        reordered[i] = reordered[i].copyWith(plan: updated);
      }
    }
    _updateExercises(reordered);
  }

  Future<void> addSet(String exercisePlanId) async {
    final exercises = _currentExercises;
    if (exercises == null) return;

    final idx = exercises.indexWhere((e) => e.plan.id == exercisePlanId);
    if (idx == -1) return;

    final currentSets = exercises[idx].sets;
    final sp = SetPlan.create(
      athleteId: _athleteId,
      exercisePlanId: exercisePlanId,
      setNumber: currentSets.length + 1,
    );
    await _setPlanRepo.create(sp);

    final updated = List<ExerciseDetailData>.from(exercises);
    updated[idx] = updated[idx].copyWith(sets: [...currentSets, sp]);
    _updateExercises(updated);
  }

  Future<void> deleteSet(String setPlanId) async {
    await _setPlanRepo.delete(setPlanId);
    final exercises = _currentExercises;
    if (exercises == null) return;

    _updateExercises(exercises.map((e) {
      if (e.sets.any((s) => s.id == setPlanId)) {
        return e.copyWith(sets: e.sets.where((s) => s.id != setPlanId).toList());
      }
      return e;
    }).toList());
  }

  Future<void> updateSet(SetPlan updated) async {
    final toSave = updated.copyWith(isDirty: true, updatedAt: DateTime.now());
    await _setPlanRepo.update(toSave);

    final exercises = _currentExercises;
    if (exercises == null) return;

    _updateExercises(exercises.map((e) {
      if (e.sets.any((s) => s.id == updated.id)) {
        return e.copyWith(
          sets: e.sets.map((s) => s.id == updated.id ? toSave : s).toList(),
        );
      }
      return e;
    }).toList());
  }

  Future<void> reorderSet(String exercisePlanId, int oldIdx, int newIdx) async {
    final exercises = _currentExercises;
    if (exercises == null) return;

    final eIdx = exercises.indexWhere((e) => e.plan.id == exercisePlanId);
    if (eIdx == -1) return;

    if (newIdx > oldIdx) newIdx -= 1;
    final sets = List<SetPlan>.from(exercises[eIdx].sets);
    final item = sets.removeAt(oldIdx);
    sets.insert(newIdx, item);

    for (int i = 0; i < sets.length; i++) {
      if (sets[i].setNumber != i + 1) {
        final updated = sets[i].copyWith(
          setNumber: i + 1,
          isDirty: true,
          updatedAt: DateTime.now(),
        );
        await _setPlanRepo.update(updated);
        sets[i] = updated;
      }
    }

    final updatedExercises = List<ExerciseDetailData>.from(exercises);
    updatedExercises[eIdx] = updatedExercises[eIdx].copyWith(sets: sets);
    _updateExercises(updatedExercises);
  }

  /// Updates the exercise referenced by an exercise plan.
  /// No-ops if the exercise hasn't changed.
  Future<void> changeExerciseInPlan(
    String exercisePlanId,
    Exercise newExercise,
  ) async {
    final exercises = _currentExercises;
    if (exercises == null) return;

    final idx = exercises.indexWhere((e) => e.plan.id == exercisePlanId);
    if (idx == -1) return;
    if (exercises[idx].exercise.id == newExercise.id) return;

    final updatedPlan = exercises[idx].plan.copyWith(
      exerciseId: newExercise.id,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
    await _exercisePlanRepo.update(updatedPlan);

    final updatedExercises = List<ExerciseDetailData>.from(exercises);
    updatedExercises[idx] = updatedExercises[idx].copyWith(
      plan: updatedPlan,
      exercise: newExercise,
    );
    _updateExercises(updatedExercises);
  }

  /// Replaces all variants for an exercise plan with [newVariants].
  /// Also updates the exercise itself if it changed.
  Future<void> replaceVariantsForExercise(
    String exercisePlanId,
    Exercise newExercise,
    List<Variant> newVariants,
  ) async {
    final exercises = _currentExercises;
    if (exercises == null) return;

    final idx = exercises.indexWhere((e) => e.plan.id == exercisePlanId);
    if (idx == -1) return;

    ExercisePlan plan = exercises[idx].plan;
    if (plan.exerciseId != newExercise.id) {
      plan = plan.copyWith(
        exerciseId: newExercise.id,
        isDirty: true,
        updatedAt: DateTime.now(),
      );
      await _exercisePlanRepo.update(plan);
    }

    final epvs = await _epvRepo.findByExercisePlanId(exercisePlanId);
    for (final epv in epvs) {
      await _epvRepo.delete(epv.id);
    }
    for (final v in newVariants) {
      await _epvRepo.create(ExercisePlanVariant.create(
        athleteId: _athleteId,
        exercisePlanId: exercisePlanId,
        variantId: v.id,
      ));
    }

    final updated = List<ExerciseDetailData>.from(exercises);
    updated[idx] = updated[idx].copyWith(
      plan: plan,
      exercise: newExercise,
      variants: newVariants,
    );
    _updateExercises(updated);
  }

  Future<void> addVariantToExercise(String exercisePlanId, Variant v) async {
    await _epvRepo.create(ExercisePlanVariant.create(
      athleteId: _athleteId,
      exercisePlanId: exercisePlanId,
      variantId: v.id,
    ));

    final exercises = _currentExercises;
    if (exercises == null) return;

    _updateExercises(exercises.map((e) {
      if (e.plan.id == exercisePlanId) {
        return e.copyWith(variants: [...e.variants, v]);
      }
      return e;
    }).toList());
  }

  Future<void> removeVariantFromExercise(
    String exercisePlanId,
    String variantId,
  ) async {
    final epvs = await _epvRepo.findByExercisePlanId(exercisePlanId);
    final epv = epvs.where((e) => e.variantId == variantId).firstOrNull;
    if (epv != null) await _epvRepo.delete(epv.id);

    final exercises = _currentExercises;
    if (exercises == null) return;

    _updateExercises(exercises.map((e) {
      if (e.plan.id == exercisePlanId) {
        return e.copyWith(
          variants: e.variants.where((v) => v.id != variantId).toList(),
        );
      }
      return e;
    }).toList());
  }

  Future<void> updateExerciseNotes(String exercisePlanId, String notes) async {
    final exercises = _currentExercises;
    if (exercises == null) return;

    final idx = exercises.indexWhere((e) => e.plan.id == exercisePlanId);
    if (idx == -1) return;

    final updated = exercises[idx].plan.copyWith(
      notes: notes.isEmpty ? null : notes,
      isDirty: true,
      updatedAt: DateTime.now(),
    );
    await _exercisePlanRepo.update(updated);

    final updatedExercises = List<ExerciseDetailData>.from(exercises);
    updatedExercises[idx] = updatedExercises[idx].copyWith(plan: updated);
    _updateExercises(updatedExercises);
  }

  Future<Exercise> createExercise(String name) async {
    final ex = Exercise.create(coachId: _coachId, name: name);
    await _exerciseRepo.create(ex);
    return ex;
  }

  Future<Variant> createVariant(String name) async {
    final v = Variant.create(coachId: _coachId, name: name);
    await _variantRepo.create(v);
    return v;
  }

  Future<List<Exercise>> searchExercises(String query) =>
      _exerciseRepo.findAllActive().then(
        (all) => query.isEmpty
            ? all
            : all
                .where(
                  (e) =>
                      e.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList(),
      );

  Future<List<Variant>> allVariants() => _variantRepo.findAllActive();

  /// Copies the current training to [targetDate].
  /// Returns true on success, false if [targetDate] already has a training.
  Future<bool> copyToDate(String targetDate, {bool fromSession = false}) async {
    final plan = _currentPlan;
    final exercises = state.maybeWhen(
      editionMode: (p, ex) => ex,
      seeMode: (p, s, ex) => ex,
      orElse: () => null,
    );
    if (plan == null || exercises == null) return false;

    final existing = await _planRepo.findByAthleteBetweenDates(
      _athleteId,
      targetDate,
      targetDate,
    );
    if (existing.isNotEmpty) return false;

    final newPlan = TrainingPlan.create(
      athleteId: _athleteId,
      name: plan.name,
      date: targetDate,
    );
    await _planRepo.create(newPlan);

    for (final ex in exercises) {
      final newEp = ExercisePlan.create(
        athleteId: _athleteId,
        trainingPlanId: newPlan.id,
        exerciseId: ex.exercise.id,
        orderIndex: ex.plan.orderIndex,
        notes: ex.plan.notes,
      );
      await _exercisePlanRepo.create(newEp);

      final variantsToCopy = fromSession && ex.sessionVariants.isNotEmpty
          ? ex.sessionVariants
          : ex.variants;
      for (final v in variantsToCopy) {
        await _epvRepo.create(ExercisePlanVariant.create(
          athleteId: _athleteId,
          exercisePlanId: newEp.id,
          variantId: v.id,
        ));
      }

      if (fromSession && ex.sessionSets.isNotEmpty) {
        for (int i = 0; i < ex.sessionSets.length; i++) {
          final ss = ex.sessionSets[i];
          await _setPlanRepo.create(SetPlan.create(
            athleteId: _athleteId,
            exercisePlanId: newEp.id,
            setNumber: ss.setNumber ?? (i + 1),
            targetReps: ss.actualReps,
            targetWeight: ss.actualWeight,
            targetRpe: ss.actualRpe,
            notes: ss.notes,
          ));
        }
      } else {
        for (final sp in ex.sets) {
          await _setPlanRepo.create(SetPlan.create(
            athleteId: _athleteId,
            exercisePlanId: newEp.id,
            setNumber: sp.setNumber,
            targetReps: sp.targetReps,
            targetWeight: sp.targetWeight,
            targetRpe: sp.targetRpe,
            notes: sp.notes,
          ));
        }
      }
    }

    return true;
  }

  /// Copies all trainings from the week starting on [sourceMonday] to the
  /// week starting on [targetMonday] (both in YYYY-MM-DD format, must be Mondays).
  /// Returns [CopyWeekResult.conflict] listing occupied target days if any clash.
  Future<CopyWeekResult> copyWeek(
    String sourceMonday,
    String targetMonday, {
    bool fromSession = false,
  }) async {
    final sourceSunday = _addDays(sourceMonday, 6);
    final targetSunday = _addDays(targetMonday, 6);

    final sourcePlans = await _planRepo.findByAthleteBetweenDates(
      _athleteId,
      sourceMonday,
      sourceSunday,
    );
    if (sourcePlans.isEmpty) return CopyWeekResult.empty;

    final targetPlans = await _planRepo.findByAthleteBetweenDates(
      _athleteId,
      targetMonday,
      targetSunday,
    );
    final occupiedDates = targetPlans.map((p) => p.date).toSet();

    final conflicts = <String>[];
    for (final plan in sourcePlans) {
      final targetDate = _addDays(targetMonday, _dayOffset(sourceMonday, plan.date));
      if (occupiedDates.contains(targetDate)) conflicts.add(targetDate);
    }
    if (conflicts.isNotEmpty) return CopyWeekResult.conflict(conflicts);

    for (final plan in sourcePlans) {
      final targetDate = _addDays(targetMonday, _dayOffset(sourceMonday, plan.date));
      await _deepCopyPlan(plan, targetDate);
    }
    return CopyWeekResult.success;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _deepCopyPlan(TrainingPlan plan, String targetDate) async {
    final newPlan = TrainingPlan.create(
      athleteId: _athleteId,
      name: plan.name,
      date: targetDate,
    );
    await _planRepo.create(newPlan);

    final exercisePlans = await _exercisePlanRepo.findByTrainingPlanId(plan.id);
    exercisePlans.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    for (final ep in exercisePlans) {
      final newEp = ExercisePlan.create(
        athleteId: _athleteId,
        trainingPlanId: newPlan.id,
        exerciseId: ep.exerciseId,
        orderIndex: ep.orderIndex,
        notes: ep.notes,
      );
      await _exercisePlanRepo.create(newEp);

      final epvs = await _epvRepo.findByExercisePlanId(ep.id);
      for (final epv in epvs) {
        await _epvRepo.create(ExercisePlanVariant.create(
          athleteId: _athleteId,
          exercisePlanId: newEp.id,
          variantId: epv.variantId,
        ));
      }

      final sets = await _setPlanRepo.findByExercisePlanId(ep.id);
      sets.sort((a, b) => (a.setNumber ?? 0).compareTo(b.setNumber ?? 0));
      for (final sp in sets) {
        await _setPlanRepo.create(SetPlan.create(
          athleteId: _athleteId,
          exercisePlanId: newEp.id,
          setNumber: sp.setNumber,
          targetReps: sp.targetReps,
          targetWeight: sp.targetWeight,
          targetRpe: sp.targetRpe,
          notes: sp.notes,
        ));
      }
    }
  }

  static String _addDays(String dateKey, int days) {
    final p = dateKey.split('-');
    final dt = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]))
        .add(Duration(days: days));
    return '${dt.year.toString().padLeft(4, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}';
  }

  static int _dayOffset(String from, String to) {
    final fp = from.split('-');
    final tp = to.split('-');
    final fromDt = DateTime(int.parse(fp[0]), int.parse(fp[1]), int.parse(fp[2]));
    final toDt = DateTime(int.parse(tp[0]), int.parse(tp[1]), int.parse(tp[2]));
    return toDt.difference(fromDt).inDays;
  }

  TrainingPlan? get _currentPlan => state.maybeWhen(
        editionMode: (plan, exercises) => plan,
        seeMode: (plan, session, exercises) => plan,
        orElse: () => null,
      );

  List<ExerciseDetailData>? get _currentExercises => state.maybeWhen(
        editionMode: (plan, exercises) => exercises,
        orElse: () => null,
      );

  void _mutatePlan(TrainingPlan updated) {
    state.maybeWhen(
      editionMode: (_, exercises) {
        state = TrainingDetailState.editionMode(plan: updated, exercises: exercises);
      },
      seeMode: (_, session, exercises) {
        state = TrainingDetailState.seeMode(
          plan: updated,
          session: session,
          exercises: exercises,
        );
      },
      orElse: () {},
    );
  }

  void _updateExercises(List<ExerciseDetailData> exercises) {
    state.maybeWhen(
      editionMode: (plan, _) {
        state = TrainingDetailState.editionMode(plan: plan, exercises: exercises);
      },
      orElse: () {},
    );
  }

  Future<List<ExerciseDetailData>> _loadExercisesForPlan(
    String planId, {
    TrainingSession? session,
  }) async {
    final exercisePlans = await _exercisePlanRepo.findByTrainingPlanId(planId);
    exercisePlans.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    List<ExerciseSession> exerciseSessions = [];
    if (session != null) {
      exerciseSessions =
          await _exerciseSessionRepo.findByTrainingSessionId(session.id);
    }

    final result = <ExerciseDetailData>[];
    for (final ep in exercisePlans) {
      final exercise = await _exerciseRepo.findById(ep.exerciseId);
      if (exercise == null) continue;

      final epvs = await _epvRepo.findByExercisePlanId(ep.id);
      final variants = <Variant>[];
      for (final epv in epvs) {
        final v = await _variantRepo.findById(epv.variantId);
        if (v != null) variants.add(v);
      }

      final sets = await _setPlanRepo.findByExercisePlanId(ep.id);
      sets.sort((a, b) => (a.setNumber ?? 0).compareTo(b.setNumber ?? 0));

      ExerciseSession? exSession;
      List<Variant> sessionVariants = [];
      List<SetSession> sessionSets = [];

      if (session != null) {
        exSession = exerciseSessions
            .where((es) => es.exercisePlanId == ep.id)
            .firstOrNull;

        if (exSession != null) {
          final esvs = await _esvRepo.findByExerciseSessionId(exSession.id);
          for (final esv in esvs) {
            final v = await _variantRepo.findById(esv.variantId);
            if (v != null) sessionVariants.add(v);
          }
          sessionSets =
              await _setSessionRepo.findByExerciseSessionId(exSession.id);
          sessionSets.sort(
            (a, b) => (a.setNumber ?? 0).compareTo(b.setNumber ?? 0),
          );
        }
      }

      result.add(ExerciseDetailData(
        plan: ep,
        exercise: exercise,
        variants: variants,
        sets: sets,
        session: exSession,
        sessionVariants: sessionVariants,
        sessionSets: sessionSets,
      ));
    }
    return result;
  }
}
