// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncPullRequestDtoImpl _$$SyncPullRequestDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SyncPullRequestDtoImpl(
  entityTypes: (json['entityTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lastSyncTime: json['lastSyncTime'] == null
      ? null
      : DateTime.parse(json['lastSyncTime'] as String),
);

Map<String, dynamic> _$$SyncPullRequestDtoImplToJson(
  _$SyncPullRequestDtoImpl instance,
) => <String, dynamic>{
  'entityTypes': instance.entityTypes,
  'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
};

_$SyncPullResponseDtoImpl _$$SyncPullResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SyncPullResponseDtoImpl(
  entities: (json['entities'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
    ),
  ),
  syncTimestamp: DateTime.parse(json['syncTimestamp'] as String),
  totalEntities: (json['totalEntities'] as num).toInt(),
);

Map<String, dynamic> _$$SyncPullResponseDtoImplToJson(
  _$SyncPullResponseDtoImpl instance,
) => <String, dynamic>{
  'entities': instance.entities,
  'syncTimestamp': instance.syncTimestamp.toIso8601String(),
  'totalEntities': instance.totalEntities,
};

_$SyncPushRequestDtoImpl _$$SyncPushRequestDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SyncPushRequestDtoImpl(
  entities: (json['entities'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>).map((e) => e as Map<String, dynamic>).toList(),
    ),
  ),
);

Map<String, dynamic> _$$SyncPushRequestDtoImplToJson(
  _$SyncPushRequestDtoImpl instance,
) => <String, dynamic>{'entities': instance.entities};

_$SyncPushResponseDtoImpl _$$SyncPushResponseDtoImplFromJson(
  Map<String, dynamic> json,
) => _$SyncPushResponseDtoImpl(
  successCount: (json['successCount'] as num).toInt(),
  failureCount: (json['failureCount'] as num).toInt(),
  failures: (json['failures'] as List<dynamic>)
      .map((e) => EntityFailure.fromJson(e as Map<String, dynamic>))
      .toList(),
  syncTimestamp: DateTime.parse(json['syncTimestamp'] as String),
);

Map<String, dynamic> _$$SyncPushResponseDtoImplToJson(
  _$SyncPushResponseDtoImpl instance,
) => <String, dynamic>{
  'successCount': instance.successCount,
  'failureCount': instance.failureCount,
  'failures': instance.failures.map((e) => e.toJson()).toList(),
  'syncTimestamp': instance.syncTimestamp.toIso8601String(),
};

_$EntityFailureImpl _$$EntityFailureImplFromJson(Map<String, dynamic> json) =>
    _$EntityFailureImpl(
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      errors: (json['errors'] as List<dynamic>)
          .map((e) => ValidationError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$EntityFailureImplToJson(_$EntityFailureImpl instance) =>
    <String, dynamic>{
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'errors': instance.errors.map((e) => e.toJson()).toList(),
    };

_$ValidationErrorImpl _$$ValidationErrorImplFromJson(
  Map<String, dynamic> json,
) => _$ValidationErrorImpl(
  field: json['field'] as String,
  code: json['code'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$$ValidationErrorImplToJson(
  _$ValidationErrorImpl instance,
) => <String, dynamic>{
  'field': instance.field,
  'code': instance.code,
  'message': instance.message,
};
