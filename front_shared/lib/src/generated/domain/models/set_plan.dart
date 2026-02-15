import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'set_plan.freezed.dart';
part 'set_plan.g.dart';


@freezed
class SetPlan with _$SetPlan implements SyncableEntity {
  const factory SetPlan({
    required String id,
    required String athleteId,
    required String exercisePlanId,
    int? setNumber,
    int? targetReps,
    double? targetWeight,
    double? targetRpe,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _SetPlan;

  factory SetPlan.fromJson(Map<String, dynamic> json) =>
      _$SetPlanFromJson(json);

  const SetPlan._();

  /// Factory for creating a new setPlan
  factory SetPlan.create({
    required String athleteId,
    required String exercisePlanId,
    int? setNumber,
    int? targetReps,
    double? targetWeight,
    double? targetRpe,
    String? notes,
  }) {
    final now = DateTime.now();
    return SetPlan(
      id: const Uuid().v4(),
      athleteId: athleteId,
      exercisePlanId: exercisePlanId,
      setNumber: setNumber,
      targetReps: targetReps,
      targetWeight: targetWeight,
      targetRpe: targetRpe,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  SetPlan markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  SetPlan softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
