// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SetPlan _$SetPlanFromJson(Map<String, dynamic> json) {
  return _SetPlan.fromJson(json);
}

/// @nodoc
mixin _$SetPlan {
  String get id => throw _privateConstructorUsedError;
  String get exercisePlanId => throw _privateConstructorUsedError;
  int get setNumber => throw _privateConstructorUsedError;
  int? get targetReps => throw _privateConstructorUsedError;
  double? get targetWeight => throw _privateConstructorUsedError;
  double? get targetRpe => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isDirty => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this SetPlan to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetPlanCopyWith<SetPlan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetPlanCopyWith<$Res> {
  factory $SetPlanCopyWith(SetPlan value, $Res Function(SetPlan) then) =
      _$SetPlanCopyWithImpl<$Res, SetPlan>;
  @useResult
  $Res call({
    String id,
    String exercisePlanId,
    int setNumber,
    int? targetReps,
    double? targetWeight,
    double? targetRpe,
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
class _$SetPlanCopyWithImpl<$Res, $Val extends SetPlan>
    implements $SetPlanCopyWith<$Res> {
  _$SetPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exercisePlanId = null,
    Object? setNumber = null,
    Object? targetReps = freezed,
    Object? targetWeight = freezed,
    Object? targetRpe = freezed,
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
            exercisePlanId: null == exercisePlanId
                ? _value.exercisePlanId
                : exercisePlanId // ignore: cast_nullable_to_non_nullable
                      as String,
            setNumber: null == setNumber
                ? _value.setNumber
                : setNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            targetReps: freezed == targetReps
                ? _value.targetReps
                : targetReps // ignore: cast_nullable_to_non_nullable
                      as int?,
            targetWeight: freezed == targetWeight
                ? _value.targetWeight
                : targetWeight // ignore: cast_nullable_to_non_nullable
                      as double?,
            targetRpe: freezed == targetRpe
                ? _value.targetRpe
                : targetRpe // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SetPlanImplCopyWith<$Res> implements $SetPlanCopyWith<$Res> {
  factory _$$SetPlanImplCopyWith(
    _$SetPlanImpl value,
    $Res Function(_$SetPlanImpl) then,
  ) = __$$SetPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String exercisePlanId,
    int setNumber,
    int? targetReps,
    double? targetWeight,
    double? targetRpe,
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
class __$$SetPlanImplCopyWithImpl<$Res>
    extends _$SetPlanCopyWithImpl<$Res, _$SetPlanImpl>
    implements _$$SetPlanImplCopyWith<$Res> {
  __$$SetPlanImplCopyWithImpl(
    _$SetPlanImpl _value,
    $Res Function(_$SetPlanImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetPlan
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? exercisePlanId = null,
    Object? setNumber = null,
    Object? targetReps = freezed,
    Object? targetWeight = freezed,
    Object? targetRpe = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? version = null,
    Object? deletedAt = freezed,
    Object? isDirty = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _$SetPlanImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        exercisePlanId: null == exercisePlanId
            ? _value.exercisePlanId
            : exercisePlanId // ignore: cast_nullable_to_non_nullable
                  as String,
        setNumber: null == setNumber
            ? _value.setNumber
            : setNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        targetReps: freezed == targetReps
            ? _value.targetReps
            : targetReps // ignore: cast_nullable_to_non_nullable
                  as int?,
        targetWeight: freezed == targetWeight
            ? _value.targetWeight
            : targetWeight // ignore: cast_nullable_to_non_nullable
                  as double?,
        targetRpe: freezed == targetRpe
            ? _value.targetRpe
            : targetRpe // ignore: cast_nullable_to_non_nullable
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
class _$SetPlanImpl extends _SetPlan {
  const _$SetPlanImpl({
    required this.id,
    required this.exercisePlanId,
    required this.setNumber,
    this.targetReps,
    this.targetWeight,
    this.targetRpe,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.deletedAt,
    this.isDirty = false,
    this.lastSyncedAt,
  }) : super._();

  factory _$SetPlanImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetPlanImplFromJson(json);

  @override
  final String id;
  @override
  final String exercisePlanId;
  @override
  final int setNumber;
  @override
  final int? targetReps;
  @override
  final double? targetWeight;
  @override
  final double? targetRpe;
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
    return 'SetPlan(id: $id, exercisePlanId: $exercisePlanId, setNumber: $setNumber, targetReps: $targetReps, targetWeight: $targetWeight, targetRpe: $targetRpe, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, version: $version, deletedAt: $deletedAt, isDirty: $isDirty, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.exercisePlanId, exercisePlanId) ||
                other.exercisePlanId == exercisePlanId) &&
            (identical(other.setNumber, setNumber) ||
                other.setNumber == setNumber) &&
            (identical(other.targetReps, targetReps) ||
                other.targetReps == targetReps) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.targetRpe, targetRpe) ||
                other.targetRpe == targetRpe) &&
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
    exercisePlanId,
    setNumber,
    targetReps,
    targetWeight,
    targetRpe,
    notes,
    createdAt,
    updatedAt,
    version,
    deletedAt,
    isDirty,
    lastSyncedAt,
  );

  /// Create a copy of SetPlan
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetPlanImplCopyWith<_$SetPlanImpl> get copyWith =>
      __$$SetPlanImplCopyWithImpl<_$SetPlanImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SetPlanImplToJson(this);
  }
}

abstract class _SetPlan extends SetPlan {
  const factory _SetPlan({
    required final String id,
    required final String exercisePlanId,
    required final int setNumber,
    final int? targetReps,
    final double? targetWeight,
    final double? targetRpe,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final int version,
    final DateTime? deletedAt,
    final bool isDirty,
    final DateTime? lastSyncedAt,
  }) = _$SetPlanImpl;
  const _SetPlan._() : super._();

  factory _SetPlan.fromJson(Map<String, dynamic> json) = _$SetPlanImpl.fromJson;

  @override
  String get id;
  @override
  String get exercisePlanId;
  @override
  int get setNumber;
  @override
  int? get targetReps;
  @override
  double? get targetWeight;
  @override
  double? get targetRpe;
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

  /// Create a copy of SetPlan
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetPlanImplCopyWith<_$SetPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
