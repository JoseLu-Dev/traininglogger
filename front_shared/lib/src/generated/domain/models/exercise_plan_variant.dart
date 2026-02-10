import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'exercise_plan_variant.freezed.dart';
part 'exercise_plan_variant.g.dart';


@freezed
class ExercisePlanVariant with _$ExercisePlanVariant implements SyncableEntity {
  const factory ExercisePlanVariant({
    required String id,
    required String exercisePlanId,
    required String variantId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _ExercisePlanVariant;

  factory ExercisePlanVariant.fromJson(Map<String, dynamic> json) =>
      _$ExercisePlanVariantFromJson(json);

  const ExercisePlanVariant._();

  /// Factory for creating a new exercisePlanVariant
  factory ExercisePlanVariant.create({
    required String exercisePlanId,
    required String variantId,
  }) {
    final now = DateTime.now();
    return ExercisePlanVariant(
      id: const Uuid().v4(),
      exercisePlanId: exercisePlanId,
      variantId: variantId,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  ExercisePlanVariant markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  ExercisePlanVariant softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
