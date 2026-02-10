// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'body_weight_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BodyWeightEntryImpl _$$BodyWeightEntryImplFromJson(
  Map<String, dynamic> json,
) => _$BodyWeightEntryImpl(
  id: json['id'] as String,
  athleteId: json['athleteId'] as String,
  weight: (json['weight'] as num).toDouble(),
  measurementDate: DateTime.parse(json['measurementDate'] as String),
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

Map<String, dynamic> _$$BodyWeightEntryImplToJson(
  _$BodyWeightEntryImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'athleteId': instance.athleteId,
  'weight': instance.weight,
  'measurementDate': instance.measurementDate.toIso8601String(),
  'notes': instance.notes,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'version': instance.version,
  'deletedAt': instance.deletedAt?.toIso8601String(),
  'isDirty': instance.isDirty,
  'lastSyncedAt': instance.lastSyncedAt?.toIso8601String(),
};
