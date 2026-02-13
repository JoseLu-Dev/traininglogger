// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseSessionImpl _$$ExerciseSessionImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseSessionImpl(
  id: json['id'] as String,
  trainingSessionId: json['trainingSessionId'] as String,
  exercisePlanId: json['exercisePlanId'] as String?,
  exerciseId: json['exerciseId'] as String,
  orderIndex: (json['orderIndex'] as num).toInt(),
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  version: (json['version'] as num?)?.toInt() ?? 0,
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
  isDirty: json['isDirty'] as bool? ?? false,
  lastSyncedAt: json['lastSyncedAt'] == null
      ? null
      : DateTime.parse(json['lastSyncedAt'] as String),
);

Map<String, dynamic> _$$ExerciseSessionImplToJson(
  _$ExerciseSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainingSessionId': instance.trainingSessionId,
  'exercisePlanId': instance.exercisePlanId,
  'exerciseId': instance.exerciseId,
  'orderIndex': instance.orderIndex,
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'isDirty': instance.isDirty,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};
