// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_weight_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BodyWeightEntry _$BodyWeightEntryFromJson(Map<String, dynamic> json) {
  return _BodyWeightEntry.fromJson(json);
}

/// @nodoc
mixin _$BodyWeightEntry {
  String get id => throw _privateConstructorUsedError;
  String get athleteId => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  DateTime get measurementDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  int get version => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool get isDirty => throw _privateConstructorUsedError;
  DateTime? get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this BodyWeightEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BodyWeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodyWeightEntryCopyWith<BodyWeightEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyWeightEntryCopyWith<$Res> {
  factory $BodyWeightEntryCopyWith(
    BodyWeightEntry value,
    $Res Function(BodyWeightEntry) then,
  ) = _$BodyWeightEntryCopyWithImpl<$Res, BodyWeightEntry>;
  @useResult
  $Res call({
    String id,
    String athleteId,
    double weight,
    DateTime measurementDate,
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
class _$BodyWeightEntryCopyWithImpl<$Res, $Val extends BodyWeightEntry>
    implements $BodyWeightEntryCopyWith<$Res> {
  _$BodyWeightEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodyWeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? athleteId = null,
    Object? weight = null,
    Object? measurementDate = null,
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
            athleteId: null == athleteId
                ? _value.athleteId
                : athleteId // ignore: cast_nullable_to_non_nullable
                      as String,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            measurementDate: null == measurementDate
                ? _value.measurementDate
                : measurementDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
abstract class _$$BodyWeightEntryImplCopyWith<$Res>
    implements $BodyWeightEntryCopyWith<$Res> {
  factory _$$BodyWeightEntryImplCopyWith(
    _$BodyWeightEntryImpl value,
    $Res Function(_$BodyWeightEntryImpl) then,
  ) = __$$BodyWeightEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String athleteId,
    double weight,
    DateTime measurementDate,
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
class __$$BodyWeightEntryImplCopyWithImpl<$Res>
    extends _$BodyWeightEntryCopyWithImpl<$Res, _$BodyWeightEntryImpl>
    implements _$$BodyWeightEntryImplCopyWith<$Res> {
  __$$BodyWeightEntryImplCopyWithImpl(
    _$BodyWeightEntryImpl _value,
    $Res Function(_$BodyWeightEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BodyWeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? athleteId = null,
    Object? weight = null,
    Object? measurementDate = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? version = null,
    Object? deletedAt = freezed,
    Object? isDirty = null,
    Object? lastSyncedAt = freezed,
  }) {
    return _then(
      _$BodyWeightEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        athleteId: null == athleteId
            ? _value.athleteId
            : athleteId // ignore: cast_nullable_to_non_nullable
                  as String,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        measurementDate: null == measurementDate
            ? _value.measurementDate
            : measurementDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
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
class _$BodyWeightEntryImpl extends _BodyWeightEntry {
  const _$BodyWeightEntryImpl({
    required this.id,
    required this.athleteId,
    required this.weight,
    required this.measurementDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.deletedAt,
    this.isDirty = false,
    this.lastSyncedAt,
  }) : super._();

  factory _$BodyWeightEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyWeightEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String athleteId;
  @override
  final double weight;
  @override
  final DateTime measurementDate;
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
    return 'BodyWeightEntry(id: $id, athleteId: $athleteId, weight: $weight, measurementDate: $measurementDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt, version: $version, deletedAt: $deletedAt, isDirty: $isDirty, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyWeightEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.athleteId, athleteId) ||
                other.athleteId == athleteId) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.measurementDate, measurementDate) ||
                other.measurementDate == measurementDate) &&
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
    athleteId,
    weight,
    measurementDate,
    notes,
    createdAt,
    updatedAt,
    version,
    deletedAt,
    isDirty,
    lastSyncedAt,
  );

  /// Create a copy of BodyWeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyWeightEntryImplCopyWith<_$BodyWeightEntryImpl> get copyWith =>
      __$$BodyWeightEntryImplCopyWithImpl<_$BodyWeightEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyWeightEntryImplToJson(this);
  }
}

abstract class _BodyWeightEntry extends BodyWeightEntry {
  const factory _BodyWeightEntry({
    required final String id,
    required final String athleteId,
    required final double weight,
    required final DateTime measurementDate,
    final String? notes,
    required final DateTime createdAt,
    required final DateTime updatedAt,
    required final int version,
    final DateTime? deletedAt,
    final bool isDirty,
    final DateTime? lastSyncedAt,
  }) = _$BodyWeightEntryImpl;
  const _BodyWeightEntry._() : super._();

  factory _BodyWeightEntry.fromJson(Map<String, dynamic> json) =
      _$BodyWeightEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get athleteId;
  @override
  double get weight;
  @override
  DateTime get measurementDate;
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

  /// Create a copy of BodyWeightEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodyWeightEntryImplCopyWith<_$BodyWeightEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
