// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TrainingSession _$TrainingSessionFromJson(Map<String, dynamic> json) {
  return _TrainingSession.fromJson(json);
}

/// @nodoc
mixin _$TrainingSession {
  String get id => throw _privateConstructorUsedError;
  String get trainingPlanId => throw _privateConstructorUsedError;
  String get athleteId => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isDirty => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this TrainingSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TrainingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TrainingSessionCopyWith<TrainingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingSessionCopyWith<$Res> {
  factory $TrainingSessionCopyWith(
    TrainingSession value,
    $Res Function(TrainingSession) then,
  ) = _$TrainingSessionCopyWithImpl<$Res, TrainingSession>;
  @useResult
  $Res call({
    String id,
    String trainingPlanId,
    String athleteId,
    DateTime startTime,
    DateTime? endTime,
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
class _$TrainingSessionCopyWithImpl<$Res, $Val extends TrainingSession>
    implements $TrainingSessionCopyWith<$Res> {
  _$TrainingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingPlanId = null,
    Object? athleteId = null,
    Object? startTime = null,
    Object? endTime = freezed,
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
            trainingPlanId: null == trainingPlanId
                ? _value.trainingPlanId
                : trainingPlanId // ignore: cast_nullable_to_non_nullable
                      as String,
            athleteId: null == athleteId
                ? _value.athleteId
                : athleteId // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$TrainingSessionImplCopyWith<$Res>
    implements $TrainingSessionCopyWith<$Res> {
  factory _$$TrainingSessionImplCopyWith(
    _$TrainingSessionImpl value,
    $Res Function(_$TrainingSessionImpl) then,
  ) = __$$TrainingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String trainingPlanId,
    String athleteId,
    DateTime startTime,
    DateTime? endTime,
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
class __$$TrainingSessionImplCopyWithImpl<$Res>
    extends _$TrainingSessionCopyWithImpl<$Res, _$TrainingSessionImpl>
    implements _$$TrainingSessionImplCopyWith<$Res> {
  __$$TrainingSessionImplCopyWithImpl(
    _$TrainingSessionImpl _value,
    $Res Function(_$TrainingSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trainingPlanId = null,
    Object? athleteId = null,
    Object? startTime = null,
    Object? endTime = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? version = null,
    Object? deletedAt = freezed,
    Object? isDirty = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _$TrainingSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        trainingPlanId: null == trainingPlanId
            ? _value.trainingPlanId
            : trainingPlanId // ignore: cast_nullable_to_non_nullable
                  as String,
        athleteId: null == athleteId
            ? _value.athleteId
            : athleteId // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$TrainingSessionImpl extends _TrainingSession {
  const _$TrainingSessionImpl({
    required this.id,
    required this.trainingPlanId,
    required this.athleteId,
    required this.startTime,
    this.endTime,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.deletedAt,
    this.isDirty = false,
    this.lastSyncedAt,
  }) : super._();

  factory _$TrainingSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainingSessionImplFromJson(json);

  @override
  final String id;
  @override
  final String trainingPlanId;
  @override
  final String athleteId;
  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;
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
    return 'TrainingSession(id: $id, trainingPlanId: $trainingPlanId, athleteId: $athleteId, startTime: $startTime, endTime: $endTime, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, version: $version, deletedAt: $deletedAt, isDirty: $isDirty, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainingSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trainingPlanId, trainingPlanId) ||
                other.trainingPlanId == trainingPlanId) &&
            (identical(other.athleteId, athleteId) ||
                other.athleteId == athleteId) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
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
    trainingPlanId,
    athleteId,
    startTime,
    endTime,
    notes,
    createdAt,
    updatedAt,
    version,
    deletedAt,
    isDirty,
    lastSyncedAt,
  );

  /// Create a copy of TrainingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainingSessionImplCopyWith<_$TrainingSessionImpl> get copyWith =>
      __$$TrainingSessionImplCopyWithImpl<_$TrainingSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainingSessionImplToJson(this);
  }
}

abstract class _TrainingSession extends TrainingSession {
  const factory _TrainingSession({
    required final String id,
    required final String trainingPlanId,
    required final String athleteId,
    required final DateTime startTime,
    final DateTime? endTime,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final int version,
    final DateTime? deletedAt,
    final bool isDirty,
    final DateTime? lastSyncedAt,
  }) = _$TrainingSessionImpl;
  const _TrainingSession._() : super._();

  factory _TrainingSession.fromJson(Map<String, dynamic> json) =
      _$TrainingSessionImpl.fromJson;

  @override
  String get id;
  @override
  String get trainingPlanId;
  @override
  String get athleteId;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;
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

  /// Create a copy of TrainingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TrainingSessionImplCopyWith<_$TrainingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
