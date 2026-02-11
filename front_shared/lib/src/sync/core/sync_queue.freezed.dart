// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_queue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$QueuedSync {
  String get id => throw _privateConstructorUsedError;
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  DateTime get queuedAt => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  DateTime get nextRetryAt => throw _privateConstructorUsedError;

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QueuedSyncCopyWith<QueuedSync> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QueuedSyncCopyWith<$Res> {
  factory $QueuedSyncCopyWith(
    QueuedSync value,
    $Res Function(QueuedSync) then,
  ) = _$QueuedSyncCopyWithImpl<$Res, QueuedSync>;
  @useResult
  $Res call({
    String id,
    String entityType,
    String entityId,
    Map<String, dynamic> data,
    DateTime queuedAt,
    int retryCount,
    DateTime nextRetryAt,
  });
}

/// @nodoc
class _$QueuedSyncCopyWithImpl<$Res, $Val extends QueuedSync>
    implements $QueuedSyncCopyWith<$Res> {
  _$QueuedSyncCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? data = null,
    Object? queuedAt = null,
    Object? retryCount = null,
    Object? nextRetryAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            entityType: null == entityType
                ? _value.entityType
                : entityType // ignore: cast_nullable_to_non_nullable
                      as String,
            entityId: null == entityId
                ? _value.entityId
                : entityId // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            queuedAt: null == queuedAt
                ? _value.queuedAt
                : queuedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            retryCount: null == retryCount
                ? _value.retryCount
                : retryCount // ignore: cast_nullable_to_non_nullable
                      as int,
            nextRetryAt: null == nextRetryAt
                ? _value.nextRetryAt
                : nextRetryAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QueuedSyncImplCopyWith<$Res>
    implements $QueuedSyncCopyWith<$Res> {
  factory _$$QueuedSyncImplCopyWith(
    _$QueuedSyncImpl value,
    $Res Function(_$QueuedSyncImpl) then,
  ) = __$$QueuedSyncImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String entityType,
    String entityId,
    Map<String, dynamic> data,
    DateTime queuedAt,
    int retryCount,
    DateTime nextRetryAt,
  });
}

/// @nodoc
class __$$QueuedSyncImplCopyWithImpl<$Res>
    extends _$QueuedSyncCopyWithImpl<$Res, _$QueuedSyncImpl>
    implements _$$QueuedSyncImplCopyWith<$Res> {
  __$$QueuedSyncImplCopyWithImpl(
    _$QueuedSyncImpl _value,
    $Res Function(_$QueuedSyncImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? data = null,
    Object? queuedAt = null,
    Object? retryCount = null,
    Object? nextRetryAt = null,
  }) {
    return _then(
      _$QueuedSyncImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        entityType: null == entityType
            ? _value.entityType
            : entityType // ignore: cast_nullable_to_non_nullable
                  as String,
        entityId: null == entityId
            ? _value.entityId
            : entityId // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        queuedAt: null == queuedAt
            ? _value.queuedAt
            : queuedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        retryCount: null == retryCount
            ? _value.retryCount
            : retryCount // ignore: cast_nullable_to_non_nullable
                  as int,
        nextRetryAt: null == nextRetryAt
            ? _value.nextRetryAt
            : nextRetryAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$QueuedSyncImpl extends _QueuedSync {
  const _$QueuedSyncImpl({
    required this.id,
    required this.entityType,
    required this.entityId,
    required final Map<String, dynamic> data,
    required this.queuedAt,
    required this.retryCount,
    required this.nextRetryAt,
  }) : _data = data,
       super._();

  @override
  final String id;
  @override
  final String entityType;
  @override
  final String entityId;
  final Map<String, dynamic> _data;
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final DateTime queuedAt;
  @override
  final int retryCount;
  @override
  final DateTime nextRetryAt;

  @override
  String toString() {
    return 'QueuedSync(id: $id, entityType: $entityType, entityId: $entityId, data: $data, queuedAt: $queuedAt, retryCount: $retryCount, nextRetryAt: $nextRetryAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QueuedSyncImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.queuedAt, queuedAt) ||
                other.queuedAt == queuedAt) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.nextRetryAt, nextRetryAt) ||
                other.nextRetryAt == nextRetryAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    entityType,
    entityId,
    const DeepCollectionEquality().hash(_data),
    queuedAt,
    retryCount,
    nextRetryAt,
  );

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QueuedSyncImplCopyWith<_$QueuedSyncImpl> get copyWith =>
      __$$QueuedSyncImplCopyWithImpl<_$QueuedSyncImpl>(this, _$identity);
}

abstract class _QueuedSync extends QueuedSync {
  const factory _QueuedSync({
    required final String id,
    required final String entityType,
    required final String entityId,
    required final Map<String, dynamic> data,
    required final DateTime queuedAt,
    required final int retryCount,
    required final DateTime nextRetryAt,
  }) = _$QueuedSyncImpl;
  const _QueuedSync._() : super._();

  @override
  String get id;
  @override
  String get entityType;
  @override
  String get entityId;
  @override
  Map<String, dynamic> get data;
  @override
  DateTime get queuedAt;
  @override
  int get retryCount;
  @override
  DateTime get nextRetryAt;

  /// Create a copy of QueuedSync
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QueuedSyncImplCopyWith<_$QueuedSyncImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
