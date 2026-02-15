// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_session_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExerciseSessionVariantImpl _$$ExerciseSessionVariantImplFromJson(
  Map<String, dynamic> json,
) => _$ExerciseSessionVariantImpl(
  id: json['id'] as String,
  athleteId: json['athleteId'] as String,
  exerciseSessionId: json['exerciseSessionId'] as String,
  variantId: json['variantId'] as String,
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

Map<String, dynamic> _$$ExerciseSessionVariantImplToJson(
  _$ExerciseSessionVariantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'athleteId': instance.athleteId,
  'exerciseSessionId': instance.exerciseSessionId,
  'variantId': instance.variantId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'isDirty': instance.isDirty,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};
