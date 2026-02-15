// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_plan_variant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExercisePlanVariantImpl _$$ExercisePlanVariantImplFromJson(
  Map<String, dynamic> json,
) => _$ExercisePlanVariantImpl(
  id: json['id'] as String,
  athleteId: json['athleteId'] as String,
  exercisePlanId: json['exercisePlanId'] as String,
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

Map<String, dynamic> _$$ExercisePlanVariantImplToJson(
  _$ExercisePlanVariantImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'athleteId': instance.athleteId,
  'exercisePlanId': instance.exercisePlanId,
  'variantId': instance.variantId,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'isDirty': instance.isDirty,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};
