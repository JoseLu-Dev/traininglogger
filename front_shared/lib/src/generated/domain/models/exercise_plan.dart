import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'exercise_plan.freezed.dart';
part 'exercise_plan.g.dart';


@freezed
class ExercisePlan with _$ExercisePlan implements SyncableEntity {
  const factory ExercisePlan({
    required String id,
    required String trainingPlanId,
    required String exerciseId,
    required int orderIndex,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _ExercisePlan;

  factory ExercisePlan.fromJson(Map<String, dynamic> json) =>
      _$ExercisePlanFromJson(json);

  const ExercisePlan._();

  /// Factory for creating a new exercisePlan
  factory ExercisePlan.create({
    required String trainingPlanId,
    required String exerciseId,
    required int orderIndex,
    String? notes,
  }) {
    final now = DateTime.now();
    return ExercisePlan(
      id: const Uuid().v4(),
      trainingPlanId: trainingPlanId,
      exerciseId: exerciseId,
      orderIndex: orderIndex,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  ExercisePlan markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  ExercisePlan softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
