import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'training_session.freezed.dart';
part 'training_session.g.dart';


@freezed
class TrainingSession with _$TrainingSession implements SyncableEntity {
  const factory TrainingSession({
    required String id,
    required String trainingPlanId,
    required String athleteId,
    required String sessionDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _TrainingSession;

  factory TrainingSession.fromJson(Map<String, dynamic> json) =>
      _$TrainingSessionFromJson(json);

  const TrainingSession._();

  /// Factory for creating a new trainingSession
  factory TrainingSession.create({
    required String trainingPlanId,
    required String athleteId,
    required String sessionDate,
    String? notes,
  }) {
    final now = DateTime.now();
    return TrainingSession(
      id: const Uuid().v4(),
      trainingPlanId: trainingPlanId,
      athleteId: athleteId,
      sessionDate: sessionDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  TrainingSession markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  TrainingSession softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
