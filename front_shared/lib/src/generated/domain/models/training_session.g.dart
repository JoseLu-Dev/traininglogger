// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrainingSessionImpl _$$TrainingSessionImplFromJson(
  Map<String, dynamic> json,
) => _$TrainingSessionImpl(
  id: json['id'] as String,
  trainingPlanId: json['trainingPlanId'] as String,
  athleteId: json['athleteId'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
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

Map<String, dynamic> _$$TrainingSessionImplToJson(
  _$TrainingSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'trainingPlanId': instance.trainingPlanId,
  'athleteId': instance.athleteId,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'isDirty': instance.isDirty,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};
