// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_dtos.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SyncPullRequestDto _$SyncPullRequestDtoFromJson(Map<String, dynamic> json) {
  return _SyncPullRequestDto.fromJson(json);
}

/// @nodoc
mixin _$SyncPullRequestDto {
  List<String> get entityTypes => throw _privateConstructorUsedError;
  DateTime? get lastSyncTime => throw _privateConstructorUsedError;

  /// Serializes this SyncPullRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPullRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPullRequestDtoCopyWith<SyncPullRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPullRequestDtoCopyWith<$Res> {
  factory $SyncPullRequestDtoCopyWith(
    SyncPullRequestDto value,
    $Res Function(SyncPullRequestDto) then,
  ) = _$SyncPullRequestDtoCopyWithImpl<$Res, SyncPullRequestDto>;
  @useResult
  $Res call({List<String> entityTypes, DateTime? lastSyncTime});
}

/// @nodoc
class _$SyncPullRequestDtoCopyWithImpl<$Res, $Val extends SyncPullRequestDto>
    implements $SyncPullRequestDtoCopyWith<$Res> {
  _$SyncPullRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPullRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entityTypes = null, Object? lastSyncTime = freezed}) {
    return _then(
      _value.copyWith(
            entityTypes: null == entityTypes
                ? _value.entityTypes
                : entityTypes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lastSyncTime: freezed == lastSyncTime
                ? _value.lastSyncTime
                : lastSyncTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncPullRequestDtoImplCopyWith<$Res>
    implements $SyncPullRequestDtoCopyWith<$Res> {
  factory _$$SyncPullRequestDtoImplCopyWith(
    _$SyncPullRequestDtoImpl value,
    $Res Function(_$SyncPullRequestDtoImpl) then,
  ) = __$$SyncPullRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<String> entityTypes, DateTime? lastSyncTime});
}

/// @nodoc
class __$$SyncPullRequestDtoImplCopyWithImpl<$Res>
    extends _$SyncPullRequestDtoCopyWithImpl<$Res, _$SyncPullRequestDtoImpl>
    implements _$$SyncPullRequestDtoImplCopyWith<$Res> {
  __$$SyncPullRequestDtoImplCopyWithImpl(
    _$SyncPullRequestDtoImpl _value,
    $Res Function(_$SyncPullRequestDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncPullRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entityTypes = null, Object? lastSyncTime = freezed}) {
    return _then(
      _$SyncPullRequestDtoImpl(
        entityTypes: null == entityTypes
            ? _value._entityTypes
            : entityTypes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lastSyncTime: freezed == lastSyncTime
            ? _value.lastSyncTime
            : lastSyncTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPullRequestDtoImpl implements _SyncPullRequestDto {
  const _$SyncPullRequestDtoImpl({
    required final List<String> entityTypes,
    this.lastSyncTime,
  }) : _entityTypes = entityTypes;

  factory _$SyncPullRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPullRequestDtoImplFromJson(json);

  final List<String> _entityTypes;
  @override
  List<String> get entityTypes {
    if (_entityTypes is EqualUnmodifiableListView) return _entityTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entityTypes);
  }

  @override
  final DateTime? lastSyncTime;

  @override
  String toString() {
    return 'SyncPullRequestDto(entityTypes: $entityTypes, lastSyncTime: $lastSyncTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPullRequestDtoImpl &&
            const DeepCollectionEquality().equals(
              other._entityTypes,
              _entityTypes,
            ) &&
            (identical(other.lastSyncTime, lastSyncTime) ||
                other.lastSyncTime == lastSyncTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_entityTypes),
    lastSyncTime,
  );

  /// Create a copy of SyncPullRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPullRequestDtoImplCopyWith<_$SyncPullRequestDtoImpl> get copyWith =>
      __$$SyncPullRequestDtoImplCopyWithImpl<_$SyncPullRequestDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPullRequestDtoImplToJson(this);
  }
}

abstract class _SyncPullRequestDto implements SyncPullRequestDto {
  const factory _SyncPullRequestDto({
    required final List<String> entityTypes,
    final DateTime? lastSyncTime,
  }) = _$SyncPullRequestDtoImpl;

  factory _SyncPullRequestDto.fromJson(Map<String, dynamic> json) =
      _$SyncPullRequestDtoImpl.fromJson;

  @override
  List<String> get entityTypes;
  @override
  DateTime? get lastSyncTime;

  /// Create a copy of SyncPullRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPullRequestDtoImplCopyWith<_$SyncPullRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncPullResponseDto _$SyncPullResponseDtoFromJson(Map<String, dynamic> json) {
  return _SyncPullResponseDto.fromJson(json);
}

/// @nodoc
mixin _$SyncPullResponseDto {
  Map<String, List<Map<String, dynamic>>> get entities =>
      throw _privateConstructorUsedError;
  DateTime get syncTimestamp => throw _privateConstructorUsedError;
  int get totalEntities => throw _privateConstructorUsedError;

  /// Serializes this SyncPullResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPullResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPullResponseDtoCopyWith<SyncPullResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPullResponseDtoCopyWith<$Res> {
  factory $SyncPullResponseDtoCopyWith(
    SyncPullResponseDto value,
    $Res Function(SyncPullResponseDto) then,
  ) = _$SyncPullResponseDtoCopyWithImpl<$Res, SyncPullResponseDto>;
  @useResult
  $Res call({
    Map<String, List<Map<String, dynamic>>> entities,
    DateTime syncTimestamp,
    int totalEntities,
  });
}

/// @nodoc
class _$SyncPullResponseDtoCopyWithImpl<$Res, $Val extends SyncPullResponseDto>
    implements $SyncPullResponseDtoCopyWith<$Res> {
  _$SyncPullResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPullResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entities = null,
    Object? syncTimestamp = null,
    Object? totalEntities = null,
  }) {
    return _then(
      _value.copyWith(
            entities: null == entities
                ? _value.entities
                : entities // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<Map<String, dynamic>>>,
            syncTimestamp: null == syncTimestamp
                ? _value.syncTimestamp
                : syncTimestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalEntities: null == totalEntities
                ? _value.totalEntities
                : totalEntities // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncPullResponseDtoImplCopyWith<$Res>
    implements $SyncPullResponseDtoCopyWith<$Res> {
  factory _$$SyncPullResponseDtoImplCopyWith(
    _$SyncPullResponseDtoImpl value,
    $Res Function(_$SyncPullResponseDtoImpl) then,
  ) = __$$SyncPullResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<String, List<Map<String, dynamic>>> entities,
    DateTime syncTimestamp,
    int totalEntities,
  });
}

/// @nodoc
class __$$SyncPullResponseDtoImplCopyWithImpl<$Res>
    extends _$SyncPullResponseDtoCopyWithImpl<$Res, _$SyncPullResponseDtoImpl>
    implements _$$SyncPullResponseDtoImplCopyWith<$Res> {
  __$$SyncPullResponseDtoImplCopyWithImpl(
    _$SyncPullResponseDtoImpl _value,
    $Res Function(_$SyncPullResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncPullResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entities = null,
    Object? syncTimestamp = null,
    Object? totalEntities = null,
  }) {
    return _then(
      _$SyncPullResponseDtoImpl(
        entities: null == entities
            ? _value._entities
            : entities // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<Map<String, dynamic>>>,
        syncTimestamp: null == syncTimestamp
            ? _value.syncTimestamp
            : syncTimestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalEntities: null == totalEntities
            ? _value.totalEntities
            : totalEntities // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPullResponseDtoImpl implements _SyncPullResponseDto {
  const _$SyncPullResponseDtoImpl({
    required final Map<String, List<Map<String, dynamic>>> entities,
    required this.syncTimestamp,
    required this.totalEntities,
  }) : _entities = entities;

  factory _$SyncPullResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPullResponseDtoImplFromJson(json);

  final Map<String, List<Map<String, dynamic>>> _entities;
  @override
  Map<String, List<Map<String, dynamic>>> get entities {
    if (_entities is EqualUnmodifiableMapView) return _entities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_entities);
  }

  @override
  final DateTime syncTimestamp;
  @override
  final int totalEntities;

  @override
  String toString() {
    return 'SyncPullResponseDto(entities: $entities, syncTimestamp: $syncTimestamp, totalEntities: $totalEntities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPullResponseDtoImpl &&
            const DeepCollectionEquality().equals(other._entities, _entities) &&
            (identical(other.syncTimestamp, syncTimestamp) ||
                other.syncTimestamp == syncTimestamp) &&
            (identical(other.totalEntities, totalEntities) ||
                other.totalEntities == totalEntities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_entities),
    syncTimestamp,
    totalEntities,
  );

  /// Create a copy of SyncPullResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPullResponseDtoImplCopyWith<_$SyncPullResponseDtoImpl> get copyWith =>
      __$$SyncPullResponseDtoImplCopyWithImpl<_$SyncPullResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPullResponseDtoImplToJson(this);
  }
}

abstract class _SyncPullResponseDto implements SyncPullResponseDto {
  const factory _SyncPullResponseDto({
    required final Map<String, List<Map<String, dynamic>>> entities,
    required final DateTime syncTimestamp,
    required final int totalEntities,
  }) = _$SyncPullResponseDtoImpl;

  factory _SyncPullResponseDto.fromJson(Map<String, dynamic> json) =
      _$SyncPullResponseDtoImpl.fromJson;

  @override
  Map<String, List<Map<String, dynamic>>> get entities;
  @override
  DateTime get syncTimestamp;
  @override
  int get totalEntities;

  /// Create a copy of SyncPullResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPullResponseDtoImplCopyWith<_$SyncPullResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncPushRequestDto _$SyncPushRequestDtoFromJson(Map<String, dynamic> json) {
  return _SyncPushRequestDto.fromJson(json);
}

/// @nodoc
mixin _$SyncPushRequestDto {
  Map<String, List<Map<String, dynamic>>> get entities =>
      throw _privateConstructorUsedError;

  /// Serializes this SyncPushRequestDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPushRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPushRequestDtoCopyWith<SyncPushRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPushRequestDtoCopyWith<$Res> {
  factory $SyncPushRequestDtoCopyWith(
    SyncPushRequestDto value,
    $Res Function(SyncPushRequestDto) then,
  ) = _$SyncPushRequestDtoCopyWithImpl<$Res, SyncPushRequestDto>;
  @useResult
  $Res call({Map<String, List<Map<String, dynamic>>> entities});
}

/// @nodoc
class _$SyncPushRequestDtoCopyWithImpl<$Res, $Val extends SyncPushRequestDto>
    implements $SyncPushRequestDtoCopyWith<$Res> {
  _$SyncPushRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPushRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entities = null}) {
    return _then(
      _value.copyWith(
            entities: null == entities
                ? _value.entities
                : entities // ignore: cast_nullable_to_non_nullable
                      as Map<String, List<Map<String, dynamic>>>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncPushRequestDtoImplCopyWith<$Res>
    implements $SyncPushRequestDtoCopyWith<$Res> {
  factory _$$SyncPushRequestDtoImplCopyWith(
    _$SyncPushRequestDtoImpl value,
    $Res Function(_$SyncPushRequestDtoImpl) then,
  ) = __$$SyncPushRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Map<String, List<Map<String, dynamic>>> entities});
}

/// @nodoc
class __$$SyncPushRequestDtoImplCopyWithImpl<$Res>
    extends _$SyncPushRequestDtoCopyWithImpl<$Res, _$SyncPushRequestDtoImpl>
    implements _$$SyncPushRequestDtoImplCopyWith<$Res> {
  __$$SyncPushRequestDtoImplCopyWithImpl(
    _$SyncPushRequestDtoImpl _value,
    $Res Function(_$SyncPushRequestDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncPushRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? entities = null}) {
    return _then(
      _$SyncPushRequestDtoImpl(
        entities: null == entities
            ? _value._entities
            : entities // ignore: cast_nullable_to_non_nullable
                  as Map<String, List<Map<String, dynamic>>>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPushRequestDtoImpl implements _SyncPushRequestDto {
  const _$SyncPushRequestDtoImpl({
    required final Map<String, List<Map<String, dynamic>>> entities,
  }) : _entities = entities;

  factory _$SyncPushRequestDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPushRequestDtoImplFromJson(json);

  final Map<String, List<Map<String, dynamic>>> _entities;
  @override
  Map<String, List<Map<String, dynamic>>> get entities {
    if (_entities is EqualUnmodifiableMapView) return _entities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_entities);
  }

  @override
  String toString() {
    return 'SyncPushRequestDto(entities: $entities)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPushRequestDtoImpl &&
            const DeepCollectionEquality().equals(other._entities, _entities));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_entities));

  /// Create a copy of SyncPushRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPushRequestDtoImplCopyWith<_$SyncPushRequestDtoImpl> get copyWith =>
      __$$SyncPushRequestDtoImplCopyWithImpl<_$SyncPushRequestDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPushRequestDtoImplToJson(this);
  }
}

abstract class _SyncPushRequestDto implements SyncPushRequestDto {
  const factory _SyncPushRequestDto({
    required final Map<String, List<Map<String, dynamic>>> entities,
  }) = _$SyncPushRequestDtoImpl;

  factory _SyncPushRequestDto.fromJson(Map<String, dynamic> json) =
      _$SyncPushRequestDtoImpl.fromJson;

  @override
  Map<String, List<Map<String, dynamic>>> get entities;

  /// Create a copy of SyncPushRequestDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPushRequestDtoImplCopyWith<_$SyncPushRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncPushResponseDto _$SyncPushResponseDtoFromJson(Map<String, dynamic> json) {
  return _SyncPushResponseDto.fromJson(json);
}

/// @nodoc
mixin _$SyncPushResponseDto {
  int get successCount => throw _privateConstructorUsedError;
  int get failureCount => throw _privateConstructorUsedError;
  List<EntityFailure> get failures => throw _privateConstructorUsedError;
  DateTime get syncTimestamp => throw _privateConstructorUsedError;

  /// Serializes this SyncPushResponseDto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncPushResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncPushResponseDtoCopyWith<SyncPushResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncPushResponseDtoCopyWith<$Res> {
  factory $SyncPushResponseDtoCopyWith(
    SyncPushResponseDto value,
    $Res Function(SyncPushResponseDto) then,
  ) = _$SyncPushResponseDtoCopyWithImpl<$Res, SyncPushResponseDto>;
  @useResult
  $Res call({
    int successCount,
    int failureCount,
    List<EntityFailure> failures,
    DateTime syncTimestamp,
  });
}

/// @nodoc
class _$SyncPushResponseDtoCopyWithImpl<$Res, $Val extends SyncPushResponseDto>
    implements $SyncPushResponseDtoCopyWith<$Res> {
  _$SyncPushResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncPushResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? successCount = null,
    Object? failureCount = null,
    Object? failures = null,
    Object? syncTimestamp = null,
  }) {
    return _then(
      _value.copyWith(
            successCount: null == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failureCount: null == failureCount
                ? _value.failureCount
                : failureCount // ignore: cast_nullable_to_non_nullable
                      as int,
            failures: null == failures
                ? _value.failures
                : failures // ignore: cast_nullable_to_non_nullable
                      as List<EntityFailure>,
            syncTimestamp: null == syncTimestamp
                ? _value.syncTimestamp
                : syncTimestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncPushResponseDtoImplCopyWith<$Res>
    implements $SyncPushResponseDtoCopyWith<$Res> {
  factory _$$SyncPushResponseDtoImplCopyWith(
    _$SyncPushResponseDtoImpl value,
    $Res Function(_$SyncPushResponseDtoImpl) then,
  ) = __$$SyncPushResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int successCount,
    int failureCount,
    List<EntityFailure> failures,
    DateTime syncTimestamp,
  });
}

/// @nodoc
class __$$SyncPushResponseDtoImplCopyWithImpl<$Res>
    extends _$SyncPushResponseDtoCopyWithImpl<$Res, _$SyncPushResponseDtoImpl>
    implements _$$SyncPushResponseDtoImplCopyWith<$Res> {
  __$$SyncPushResponseDtoImplCopyWithImpl(
    _$SyncPushResponseDtoImpl _value,
    $Res Function(_$SyncPushResponseDtoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncPushResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? successCount = null,
    Object? failureCount = null,
    Object? failures = null,
    Object? syncTimestamp = null,
  }) {
    return _then(
      _$SyncPushResponseDtoImpl(
        successCount: null == successCount
            ? _value.successCount
            : successCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failureCount: null == failureCount
            ? _value.failureCount
            : failureCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failures: null == failures
            ? _value._failures
            : failures // ignore: cast_nullable_to_non_nullable
                  as List<EntityFailure>,
        syncTimestamp: null == syncTimestamp
            ? _value.syncTimestamp
            : syncTimestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncPushResponseDtoImpl implements _SyncPushResponseDto {
  const _$SyncPushResponseDtoImpl({
    required this.successCount,
    required this.failureCount,
    required final List<EntityFailure> failures,
    required this.syncTimestamp,
  }) : _failures = failures;

  factory _$SyncPushResponseDtoImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncPushResponseDtoImplFromJson(json);

  @override
  final int successCount;
  @override
  final int failureCount;
  final List<EntityFailure> _failures;
  @override
  List<EntityFailure> get failures {
    if (_failures is EqualUnmodifiableListView) return _failures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failures);
  }

  @override
  final DateTime syncTimestamp;

  @override
  String toString() {
    return 'SyncPushResponseDto(successCount: $successCount, failureCount: $failureCount, failures: $failures, syncTimestamp: $syncTimestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncPushResponseDtoImpl &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failureCount, failureCount) ||
                other.failureCount == failureCount) &&
            const DeepCollectionEquality().equals(other._failures, _failures) &&
            (identical(other.syncTimestamp, syncTimestamp) ||
                other.syncTimestamp == syncTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    successCount,
    failureCount,
    const DeepCollectionEquality().hash(_failures),
    syncTimestamp,
  );

  /// Create a copy of SyncPushResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncPushResponseDtoImplCopyWith<_$SyncPushResponseDtoImpl> get copyWith =>
      __$$SyncPushResponseDtoImplCopyWithImpl<_$SyncPushResponseDtoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncPushResponseDtoImplToJson(this);
  }
}

abstract class _SyncPushResponseDto implements SyncPushResponseDto {
  const factory _SyncPushResponseDto({
    required final int successCount,
    required final int failureCount,
    required final List<EntityFailure> failures,
    required final DateTime syncTimestamp,
  }) = _$SyncPushResponseDtoImpl;

  factory _SyncPushResponseDto.fromJson(Map<String, dynamic> json) =
      _$SyncPushResponseDtoImpl.fromJson;

  @override
  int get successCount;
  @override
  int get failureCount;
  @override
  List<EntityFailure> get failures;
  @override
  DateTime get syncTimestamp;

  /// Create a copy of SyncPushResponseDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncPushResponseDtoImplCopyWith<_$SyncPushResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EntityFailure _$EntityFailureFromJson(Map<String, dynamic> json) {
  return _EntityFailure.fromJson(json);
}

/// @nodoc
mixin _$EntityFailure {
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  List<ValidationError> get errors => throw _privateConstructorUsedError;

  /// Serializes this EntityFailure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EntityFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EntityFailureCopyWith<EntityFailure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EntityFailureCopyWith<$Res> {
  factory $EntityFailureCopyWith(
    EntityFailure value,
    $Res Function(EntityFailure) then,
  ) = _$EntityFailureCopyWithImpl<$Res, EntityFailure>;
  @useResult
  $Res call({String entityType, String entityId, List<ValidationError> errors});
}

/// @nodoc
class _$EntityFailureCopyWithImpl<$Res, $Val extends EntityFailure>
    implements $EntityFailureCopyWith<$Res> {
  _$EntityFailureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EntityFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityType = null,
    Object? entityId = null,
    Object? errors = null,
  }) {
    return _then(
      _value.copyWith(
            entityType: null == entityType
                ? _value.entityType
                : entityType // ignore: cast_nullable_to_non_nullable
                      as String,
            entityId: null == entityId
                ? _value.entityId
                : entityId // ignore: cast_nullable_to_non_nullable
                      as String,
            errors: null == errors
                ? _value.errors
                : errors // ignore: cast_nullable_to_non_nullable
                      as List<ValidationError>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EntityFailureImplCopyWith<$Res>
    implements $EntityFailureCopyWith<$Res> {
  factory _$$EntityFailureImplCopyWith(
    _$EntityFailureImpl value,
    $Res Function(_$EntityFailureImpl) then,
  ) = __$$EntityFailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String entityType, String entityId, List<ValidationError> errors});
}

/// @nodoc
class __$$EntityFailureImplCopyWithImpl<$Res>
    extends _$EntityFailureCopyWithImpl<$Res, _$EntityFailureImpl>
    implements _$$EntityFailureImplCopyWith<$Res> {
  __$$EntityFailureImplCopyWithImpl(
    _$EntityFailureImpl _value,
    $Res Function(_$EntityFailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EntityFailure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entityType = null,
    Object? entityId = null,
    Object? errors = null,
  }) {
    return _then(
      _$EntityFailureImpl(
        entityType: null == entityType
            ? _value.entityType
            : entityType // ignore: cast_nullable_to_non_nullable
                  as String,
        entityId: null == entityId
            ? _value.entityId
            : entityId // ignore: cast_nullable_to_non_nullable
                  as String,
        errors: null == errors
            ? _value._errors
            : errors // ignore: cast_nullable_to_non_nullable
                  as List<ValidationError>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$EntityFailureImpl implements _EntityFailure {
  const _$EntityFailureImpl({
    required this.entityType,
    required this.entityId,
    required final List<ValidationError> errors,
  }) : _errors = errors;

  factory _$EntityFailureImpl.fromJson(Map<String, dynamic> json) =>
      _$$EntityFailureImplFromJson(json);

  @override
  final String entityType;
  @override
  final String entityId;
  final List<ValidationError> _errors;
  @override
  List<ValidationError> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  String toString() {
    return 'EntityFailure(entityType: $entityType, entityId: $entityId, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EntityFailureImpl &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    entityType,
    entityId,
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of EntityFailure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EntityFailureImplCopyWith<_$EntityFailureImpl> get copyWith =>
      __$$EntityFailureImplCopyWithImpl<_$EntityFailureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EntityFailureImplToJson(this);
  }
}

abstract class _EntityFailure implements EntityFailure {
  const factory _EntityFailure({
    required final String entityType,
    required final String entityId,
    required final List<ValidationError> errors,
  }) = _$EntityFailureImpl;

  factory _EntityFailure.fromJson(Map<String, dynamic> json) =
      _$EntityFailureImpl.fromJson;

  @override
  String get entityType;
  @override
  String get entityId;
  @override
  List<ValidationError> get errors;

  /// Create a copy of EntityFailure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EntityFailureImplCopyWith<_$EntityFailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ValidationError _$ValidationErrorFromJson(Map<String, dynamic> json) {
  return _ValidationError.fromJson(json);
}

/// @nodoc
mixin _$ValidationError {
  String get field => throw _privateConstructorUsedError;
  String get code =>
      throw _privateConstructorUsedError; // ADDED: Backend includes error code
  String get message => throw _privateConstructorUsedError;

  /// Serializes this ValidationError to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationErrorCopyWith<ValidationError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationErrorCopyWith<$Res> {
  factory $ValidationErrorCopyWith(
    ValidationError value,
    $Res Function(ValidationError) then,
  ) = _$ValidationErrorCopyWithImpl<$Res, ValidationError>;
  @useResult
  $Res call({String field, String code, String message});
}

/// @nodoc
class _$ValidationErrorCopyWithImpl<$Res, $Val extends ValidationError>
    implements $ValidationErrorCopyWith<$Res> {
  _$ValidationErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? code = null,
    Object? message = null,
  }) {
    return _then(
      _value.copyWith(
            field: null == field
                ? _value.field
                : field // ignore: cast_nullable_to_non_nullable
                      as String,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $ValidationErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(
    _$ValidationErrorImpl value,
    $Res Function(_$ValidationErrorImpl) then,
  ) = __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String field, String code, String message});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$ValidationErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
    _$ValidationErrorImpl _value,
    $Res Function(_$ValidationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? field = null,
    Object? code = null,
    Object? message = null,
  }) {
    return _then(
      _$ValidationErrorImpl(
        field: null == field
            ? _value.field
            : field // ignore: cast_nullable_to_non_nullable
                  as String,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidationErrorImpl implements _ValidationError {
  const _$ValidationErrorImpl({
    required this.field,
    required this.code,
    required this.message,
  });

  factory _$ValidationErrorImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidationErrorImplFromJson(json);

  @override
  final String field;
  @override
  final String code;
  // ADDED: Backend includes error code
  @override
  final String message;

  @override
  String toString() {
    return 'ValidationError(field: $field, code: $code, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.field, field) || other.field == field) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, field, code, message);

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidationErrorImplToJson(this);
  }
}

abstract class _ValidationError implements ValidationError {
  const factory _ValidationError({
    required final String field,
    required final String code,
    required final String message,
  }) = _$ValidationErrorImpl;

  factory _ValidationError.fromJson(Map<String, dynamic> json) =
      _$ValidationErrorImpl.fromJson;

  @override
  String get field;
  @override
  String get code; // ADDED: Backend includes error code
  @override
  String get message;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
