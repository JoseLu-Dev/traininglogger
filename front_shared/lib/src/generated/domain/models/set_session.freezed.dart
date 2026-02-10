// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SetSession _$SetSessionFromJson(Map<String, dynamic> json) {
  return _SetSession.fromJson(json);
}

/// @nodoc
mixin _$SetSession {
  String get id => throw _privateConstructorUsedError;
  String get exerciseSessionId => throw _privateConstructorUsedError;
  String? get setPlanId => throw _privateConstructorUsedError;
  int get setNumber => throw _privateConstructorUsedError;
  int get actualReps => throw _privateConstructorUsedError;
  double get actualWeight => throw _privateConstructorUsedError;
  double? get actualRpe => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isDirty => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this SetSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetSessionCopyWith<SetSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetSessionCopyWith<$Res> {
  factory $SetSessionCopyWith(
    SetSession value,
    $Res Function(SetSession) then,
  ) = _$SetSessionCopyWithImpl<$Res, SetSession>;
  @useResult
  $Res call({
    String id,
    String exerciseSessionId,
    String? setPlanId,
    int setNumber,
    int actualReps,
    double actualWeight,
    double? actualRpe,
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
class _$SetSessionCopyWithImpl<$Res, $Val extends SetSession>
    implements $SetSessionCopyWith<$Res> {
  _$SetSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseSessionId = null,
    Object? setPlanId = freezed,
    Object? setNumber = null,
    Object? actualReps = null,
    Object? actualWeight = null,
    Object? actualRpe = freezed,
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
            exerciseSessionId: null == exerciseSessionId
                ? _value.exerciseSessionId
                : exerciseSessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            setPlanId: freezed == setPlanId
                ? _value.setPlanId
                : setPlanId // ignore: cast_nullable_to_non_nullable
                      as String?,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            actualReps: null == actualReps
                ? _value.actualReps
                : actualReps // ignore: cast_nullable_to_non_nullable
                      as int,
            actualWeight: null == actualWeight
                ? _value.actualWeight
                : actualWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            actualRpe: freezed == actualRpe
                ? _value.actualRpe
                : actualRpe // ignore: cast_nullable_to_non_nullable
                      as double?,
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
abstract class _$$SetSessionImplCopyWith<$Res>
    implements $SetSessionCopyWith<$Res> {
  factory _$$SetSessionImplCopyWith(
    _$SetSessionImpl value,
    $Res Function(_$SetSessionImpl) then,
  ) = __$$SetSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String exerciseSessionId,
    String? setPlanId,
    int setNumber,
    int actualReps,
    double actualWeight,
    double? actualRpe,
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
class __$$SetSessionImplCopyWithImpl<$Res>
    extends _$SetSessionCopyWithImpl<$Res, _$SetSessionImpl>
    implements _$$SetSessionImplCopyWith<$Res> {
  __$$SetSessionImplCopyWithImpl(
    _$SetSessionImpl _value,
    $Res Function(_$SetSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exerciseSessionId = null,
    Object? setPlanId = freezed,
    Object? setNumber = null,
    Object? actualReps = null,
    Object? actualWeight = null,
    Object? actualRpe = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? version = null,
    Object? deletedAt = freezed,
    Object? isDirty = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _$SetSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        exerciseSessionId: null == exerciseSessionId
            ? _value.exerciseSessionId
            : exerciseSessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        setPlanId: freezed == setPlanId
            ? _value.setPlanId
            : setPlanId // ignore: cast_nullable_to_non_nullable
                  as String?,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        actualReps: null == actualReps
            ? _value.actualReps
            : actualReps // ignore: cast_nullable_to_non_nullable
                  as int,
        actualWeight: null == actualWeight
            ? _value.actualWeight
            : actualWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        actualRpe: freezed == actualRpe
            ? _value.actualRpe
            : actualRpe // ignore: cast_nullable_to_non_nullable
                  as double?,
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
class _$SetSessionImpl extends _SetSession {
  const _$SetSessionImpl({
    required this.id,
    required this.exerciseSessionId,
    this.setPlanId,
    required this.setNumber,
    required this.actualReps,
    required this.actualWeight,
    this.actualRpe,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.deletedAt,
    this.isDirty = false,
    this.lastSyncedAt,
  }) : super._();

  factory _$SetSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String exerciseSessionId;
  @override
  final String? setPlanId;
  @override
  final int setNumber;
  @override
  final int actualReps;
  @override
  final double actualWeight;
  @override
  final double? actualRpe;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
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
    return 'SetSession(id: $id, exerciseSessionId: $exerciseSessionId, setPlanId: $setPlanId, setNumber: $setNumber, actualReps: $actualReps, actualWeight: $actualWeight, actualRpe: $actualRpe, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, version: $version, deletedAt: $deletedAt, isDirty: $isDirty, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exerciseSessionId, exerciseSessionId) ||
                other.exerciseSessionId == exerciseSessionId) &&
            (identical(other.setPlanId, setPlanId) ||
                other.setPlanId == setPlanId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.actualReps, actualReps) ||
                other.actualReps == actualReps) &&
            (identical(other.actualWeight, actualWeight) ||
                other.actualWeight == actualWeight) &&
            (identical(other.actualRpe, actualRpe) ||
                other.actualRpe == actualRpe) &&
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
    exerciseSessionId,
    setPlanId,
    setNumber,
    actualReps,
    actualWeight,
    actualRpe,
    notes,
    createdAt,
    updatedAt,
    version,
    deletedAt,
    isDirty,
    lastSyncedAt,
  );

  /// Create a copy of SetSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetSessionImplCopyWith<_$SetSessionImpl> get copyWith =>
      __$$SetSessionImplCopyWithImpl<_$SetSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetSessionImplToJson(this);
  }
}

abstract class _SetSession extends SetSession {
  const factory _SetSession({
    required final String id,
    required final String exerciseSessionId,
    final String? setPlanId,
    required final int setNumber,
    required final int actualReps,
    required final double actualWeight,
    final double? actualRpe,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final int version,
    final DateTime? deletedAt,
    final bool isDirty,
    final DateTime? lastSyncedAt,
  }) = _$SetSessionImpl;
  const _SetSession._() : super._();

  factory _SetSession.fromJson(Map<String, dynamic> json) =
      _$SetSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get exerciseSessionId;
  @override
  String? get setPlanId;
  @override
  int get setNumber;
  @override
  int get actualReps;
  @override
  double get actualWeight;
  @override
  double? get actualRpe;
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

  /// Create a copy of SetSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetSessionImplCopyWith<_$SetSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
