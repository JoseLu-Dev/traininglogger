import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:front_shared/src/domain/models/syncable_entity.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole { athlete, coach }

@freezed
class User with _$User implements SyncableEntity {
  const factory User({
    required String id,
    required String email,
    required String name,
    required UserRole role,
    String? coachId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int version,
    DateTime? deletedAt,
    @Default(false) bool isDirty,
    DateTime? lastSyncedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  const User._();

  /// Factory for creating a new user
  factory User.create({
    required String email,
    required String name,
    required UserRole role,
    String? coachId,
  }) {
    final now = DateTime.now();
    return User(
      id: const Uuid().v4(),
      email: email,
      name: name,
      role: role,
      coachId: coachId,
      createdAt: now,
      updatedAt: now,
      version: 1,
      isDirty: true,
    );
  }

  /// Mark entity as dirty (needs sync)
  User markDirty() => copyWith(
        isDirty: true,
        updatedAt: DateTime.now(),
      );

  /// Soft delete entity
  User softDelete() => copyWith(
        deletedAt: DateTime.now(),
        isDirty: true,
        updatedAt: DateTime.now(),
      );
}
