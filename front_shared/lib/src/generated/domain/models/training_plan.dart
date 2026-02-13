import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'training_plan.freezed.dart';
part 'training_plan.g.dart';


@freezed
class TrainingPlan with _$TrainingPlan implements SyncableEntity {
  const factory TrainingPlan({
    required String id,
    required String athleteId,
    required String name,
    required DateTime date,
    required bool isLocked,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _TrainingPlan;

  factory TrainingPlan.fromJson(Map<String, dynamic> json) =>
      _$TrainingPlanFromJson(json);

  const TrainingPlan._();

  /// Factory for creating a new trainingPlan
  factory TrainingPlan.create({
    required String athleteId,
    required String name,
    required DateTime date,
    bool isLocked = false,
  }) {
    final now = DateTime.now();
    return TrainingPlan(
      id: const Uuid().v4(),
      athleteId: athleteId,
      name: name,
      date: date,
      isLocked: isLocked,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  TrainingPlan markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  TrainingPlan softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
