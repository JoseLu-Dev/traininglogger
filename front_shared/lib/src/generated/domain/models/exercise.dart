import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';


@freezed
class Exercise with _$Exercise implements SyncableEntity {
  const factory Exercise({
    required String id,
    required String name,
    String? description,
    String? category,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);

  const Exercise._();

  /// Factory for creating a new exercise
  factory Exercise.create({
    required String name,
    String? description,
    String? category,
  }) {
    final now = DateTime.now();
    return Exercise(
      id: const Uuid().v4(),
      name: name,
      description: description,
      category: category,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  Exercise markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  Exercise softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
