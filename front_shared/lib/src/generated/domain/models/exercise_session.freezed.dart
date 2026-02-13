// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExerciseSession _$ExerciseSessionFromJson(Map<String, dynamic> json) {
  return _ExerciseSession.fromJson(json);
}

/// @nodoc
mixin _$ExerciseSession {
  String get id => throw _privateConstructorUsedError;
  String get trainingSessionId => throw _privateConstructorUsedError;
  String? get exercisePlanId => throw _privateConstructorUsedError;
  String get exerciseId => throw _privateConstructorUsedError;
  int get orderIndex => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isDirty => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this ExerciseSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseSessionCopyWith<ExerciseSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseSessionCopyWith<$Res> {
  factory $ExerciseSessionCopyWith(
    ExerciseSession value,
    $Res Function(ExerciseSession) then,
  ) = _$ExerciseSessionCopyWithImpl<$Res, ExerciseSession>;
  @useResult
  $Res call({
    String id,
    String trainingSessionId,
    String? exercisePlanId,
    String exerciseId,
    int orderIndex,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
    int version,
    DateTime? deletedAt,
    bool isDirty,
    DateTime? lastSyncedAt,
  });
}

/// @nodoc
class _$ExerciseSessionCopyWithImpl<$Res, $Val extends ExerciseSession>
    implements $ExerciseSessionCopyWith<$Res> {
  _$ExerciseSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingSessionId = null,
    Object? exercisePlanId = freezed,
    Object? exerciseId = null,
    Object? orderIndex = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? version = null,
    Object? deletedAt = freezed,
    Object? isDirty = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            trainingSessionId: null == trainingSessionId
                ? _value.trainingSessionId
                : trainingSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            exercisePlanId: freezed == exercisePlanId
                ? _value.exercisePlanId
                : exercisePlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            orderIndex: null == orderIndex
                ? _value.orderIndex
                : orderIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            version: null == version
                ? _value.version
                : version // ignore: cast_nullable_to_non_nullable
                      as int,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isDirty: null == isDirty
                ? _value.isDirty
                : isDirty // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSyncedAt: freezed == lastSyncedAt
                ? _value.lastSyncedAt
                : lastSyncedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseSessionImplCopyWith<$Res>
    implements $ExerciseSessionCopyWith<$Res> {
  factory _$$ExerciseSessionImplCopyWith(
    _$ExerciseSessionImpl value,
    $Res Function(_$ExerciseSessionImpl) then,
  ) = __$$ExerciseSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String trainingSessionId,
    String? exercisePlanId,
    String exerciseId,
    int orderIndex,
    String? notes,
    DateTime createdAt,
    DateTime updatedAt,
    int version,
    DateTime? deletedAt,
    bool isDirty,
    DateTime? lastSyncedAt,
  });
}

/// @nodoc
class __$$ExerciseSessionImplCopyWithImpl<$Res>
    extends _$ExerciseSessionCopyWithImpl<$Res, _$ExerciseSessionImpl>
    implements _$$ExerciseSessionImplCopyWith<$Res> {
  __$$ExerciseSessionImplCopyWithImpl(
    _$ExerciseSessionImpl _value,
    $Res Function(_$ExerciseSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingSessionId = null,
    Object? exercisePlanId = freezed,
    Object? exerciseId = null,
    Object? orderIndex = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? version = null,
    Object? deletedAt = freezed,
    Object? isDirty = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _$ExerciseSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        trainingSessionId: null == trainingSessionId
            ? _value.trainingSessionId
            : trainingSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        exercisePlanId: freezed == exercisePlanId
            ? _value.exercisePlanId
            : exercisePlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        orderIndex: null == orderIndex
            ? _value.orderIndex
            : orderIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        version: null == version
            ? _value.version
            : version // ignore: cast_nullable_to_non_nullable
                  as int,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isDirty: null == isDirty
            ? _value.isDirty
            : isDirty // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSyncedAt: freezed == lastSyncedAt
            ? _value.lastSyncedAt
            : lastSyncedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExerciseSessionImpl extends _ExerciseSession {
  const _$ExerciseSessionImpl({
    required this.id,
    required this.trainingSessionId,
    this.exercisePlanId,
    required this.exerciseId,
    required this.orderIndex,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.version = 0,
    this.deletedAt,
    this.isDirty = false,
    this.lastSyncedAt,
  }) : super._();

  factory _$ExerciseSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String trainingSessionId;
  @override
  final String? exercisePlanId;
  @override
  final String exerciseId;
  @override
  final int orderIndex;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  @JsonKey()
  final int version;
  @override
  final DateTime? deletedAt;
  @override
  @JsonKey()
  final bool isDirty;
  @override
  final DateTime? lastSyncedAt;

  @override
  String toString() {
    return 'ExerciseSession(id: $id, trainingSessionId: $trainingSessionId, exercisePlanId: $exercisePlanId, exerciseId: $exerciseId, orderIndex: $orderIndex, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, version: $version, deletedAt: $deletedAt, isDirty: $isDirty, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trainingSessionId, trainingSessionId) ||
                other.trainingSessionId == trainingSessionId) &&
            (identical(other.exercisePlanId, exercisePlanId) ||
                other.exercisePlanId == exercisePlanId) &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isDirty, isDirty) || other.isDirty == isDirty) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    trainingSessionId,
    exercisePlanId,
    exerciseId,
    orderIndex,
    notes,
    createdAt,
    updatedAt,
    version,
    deletedAt,
    isDirty,
    lastSyncedAt,
  );

  /// Create a copy of ExerciseSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseSessionImplCopyWith<_$ExerciseSessionImpl> get copyWith =>
      __$$ExerciseSessionImplCopyWithImpl<_$ExerciseSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseSessionImplToJson(this);
  }
}

abstract class _ExerciseSession extends ExerciseSession {
  const factory _ExerciseSession({
    required final String id,
    required final String trainingSessionId,
    final String? exercisePlanId,
    required final String exerciseId,
    required final int orderIndex,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    final int version,
    final DateTime? deletedAt,
    final bool isDirty,
    final DateTime? lastSyncedAt,
  }) = _$ExerciseSessionImpl;
  const _ExerciseSession._() : super._();

  factory _ExerciseSession.fromJson(Map<String, dynamic> json) =
      _$ExerciseSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get trainingSessionId;
  @override
  String? get exercisePlanId;
  @override
  String get exerciseId;
  @override
  int get orderIndex;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  int get version;
  @override
  DateTime? get deletedAt;
  @override
  bool get isDirty;
  @override
  DateTime? get lastSyncedAt;

  /// Create a copy of ExerciseSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseSessionImplCopyWith<_$ExerciseSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
