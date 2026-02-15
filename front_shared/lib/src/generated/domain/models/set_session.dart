import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'set_session.freezed.dart';
part 'set_session.g.dart';


@freezed
class SetSession with _$SetSession implements SyncableEntity {
  const factory SetSession({
    required String id,
    required String athleteId,
    required String exerciseSessionId,
    String? setPlanId,
    int? setNumber,
    required int actualReps,
    required double actualWeight,
    double? actualRpe,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _SetSession;

  factory SetSession.fromJson(Map<String, dynamic> json) =>
      _$SetSessionFromJson(json);

  const SetSession._();

  /// Factory for creating a new setSession
  factory SetSession.create({
    required String athleteId,
    required String exerciseSessionId,
    String? setPlanId,
    int? setNumber,
    required int actualReps,
    required double actualWeight,
    double? actualRpe,
    String? notes,
  }) {
    final now = DateTime.now();
    return SetSession(
      id: const Uuid().v4(),
      athleteId: athleteId,
      exerciseSessionId: exerciseSessionId,
      setPlanId: setPlanId,
      setNumber: setNumber,
      actualReps: actualReps,
      actualWeight: actualWeight,
      actualRpe: actualRpe,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  SetSession markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  SetSession softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
