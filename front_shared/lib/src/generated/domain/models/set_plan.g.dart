// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_plan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetPlanImpl _$$SetPlanImplFromJson(Map<String, dynamic> json) =>
    _$SetPlanImpl(
      id: json['id'] as String,
      exercisePlanId: json['exercisePlanId'] as String,
      setNumber: (json['setNumber'] as num).toInt(),
      targetReps: (json['targetReps'] as num?)?.toInt(),
      targetWeight: (json['targetWeight'] as num?)?.toDouble(),
      targetRpe: (json['targetRpe'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
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

Map<String, dynamic> _$$SetPlanImplToJson(_$SetPlanImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exercisePlanId': instance.exercisePlanId,
      'setNumber': instance.setNumber,
      'targetReps': instance.targetReps,
      'targetWeight': instance.targetWeight,
      'targetRpe': instance.targetRpe,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'version': instance.version,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'isDirty': instance.isDirty,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };
