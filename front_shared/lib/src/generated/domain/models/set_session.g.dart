// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SetSessionImpl _$$SetSessionImplFromJson(Map<String, dynamic> json) =>
    _$SetSessionImpl(
      id: json['id'] as String,
      exerciseSessionId: json['exerciseSessionId'] as String,
      setPlanId: json['setPlanId'] as String?,
      setNumber: (json['setNumber'] as num?)?.toInt(),
      actualReps: (json['actualReps'] as num).toInt(),
      actualWeight: (json['actualWeight'] as num).toDouble(),
      actualRpe: (json['actualRpe'] as num?)?.toDouble(),
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

Map<String, dynamic> _$$SetSessionImplToJson(_$SetSessionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseSessionId': instance.exerciseSessionId,
      'setPlanId': instance.setPlanId,
      'setNumber': instance.setNumber,
      'actualReps': instance.actualReps,
      'actualWeight': instance.actualWeight,
      'actualRpe': instance.actualRpe,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'version': instance.version,
      'deletedAt': instance.deletedAt?.toIso8601String(),
      'isDirty': instance.isDirty,
      'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
    };
