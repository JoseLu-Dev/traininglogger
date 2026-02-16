import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'body_weight_entry.freezed.dart';
part 'body_weight_entry.g.dart';


@freezed
class BodyWeightEntry with _$BodyWeightEntry implements SyncableEntity {
  const factory BodyWeightEntry({
    required String id,
    required String athleteId,
    required double weight,
    required String measurementDate,
    String? notes,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(0) int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _BodyWeightEntry;

  factory BodyWeightEntry.fromJson(Map<String, dynamic> json) =>
      _$BodyWeightEntryFromJson(json);

  const BodyWeightEntry._();

  /// Factory for creating a new bodyWeightEntry
  factory BodyWeightEntry.create({
    required String athleteId,
    required double weight,
    required String measurementDate,
    String? notes,
  }) {
    final now = DateTime.now();
    return BodyWeightEntry(
      id: const Uuid().v4(),
      athleteId: athleteId,
      weight: weight,
      measurementDate: measurementDate,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  BodyWeightEntry markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  BodyWeightEntry softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
