// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingPlanImpl _$$TrainingPlanImplFromJson(Map<String, dynamic> json) =>
    _$TrainingPlanImpl(
      id: json['id'] as String,
      athleteId: json['athleteId'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      isLocked: json['isLocked'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      version: (json['version'] as num).toInt(),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      isDirty: json['isDirty'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] == null
          ? null
          : DateTime.parse(json['lastSyncedAt'] as String),
    );

Map<String, dynamic> _$$TrainingPlanImplToJson(_$TrainingPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'athleteId': instance.athleteId,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'isLocked': instance.isLocked,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'version': instance.version,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'isDirty': instance.isDirty,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };
