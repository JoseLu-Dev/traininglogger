import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'exercise_session.freezed.dart';
part 'exercise_session.g.dart';


@freezed
class ExerciseSession with _$ExerciseSession implements SyncableEntity {
  const factory ExerciseSession({
    required String id,
    required String trainingSessionId,
    String? exercisePlanId,
    required String exerciseId,
    required int orderIndex,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _ExerciseSession;

  factory ExerciseSession.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSessionFromJson(json);

  const ExerciseSession._();

  /// Factory for creating a new exerciseSession
  factory ExerciseSession.create({
    required String trainingSessionId,
    String? exercisePlanId,
    required String exerciseId,
    required int orderIndex,
    String? notes,
  }) {
    final now = DateTime.now();
    return ExerciseSession(
      id: const Uuid().v4(),
      trainingSessionId: trainingSessionId,
      exercisePlanId: exercisePlanId,
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
  ExerciseSession markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  ExerciseSession softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
