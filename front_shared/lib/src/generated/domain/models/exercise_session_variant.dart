import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'exercise_session_variant.freezed.dart';
part 'exercise_session_variant.g.dart';


@freezed
class ExerciseSessionVariant with _$ExerciseSessionVariant implements SyncableEntity {
  const factory ExerciseSessionVariant({
    required String id,
    required String exerciseSessionId,
    required String variantId,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _ExerciseSessionVariant;

  factory ExerciseSessionVariant.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionVariantFromJson(json);

  const ExerciseSessionVariant._();

  /// Factory for creating a new exerciseSessionVariant
  factory ExerciseSessionVariant.create({
    required String exerciseSessionId,
    required String variantId,
  }) {
    final now = DateTime.now();
    return ExerciseSessionVariant(
      id: const Uuid().v4(),
      exerciseSessionId: exerciseSessionId,
      variantId: variantId,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  ExerciseSessionVariant markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  ExerciseSessionVariant softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
