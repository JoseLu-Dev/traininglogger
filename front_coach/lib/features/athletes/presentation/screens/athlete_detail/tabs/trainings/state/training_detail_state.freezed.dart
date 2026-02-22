// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'training_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$TrainingDetailState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function() loading,
    required TResult Function(
      TrainingPlan plan,
      List<ExerciseDetailData> exercises,
    )
    editionMode,
    required TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )
    seeMode,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function()? loading,
    TResult? Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult? Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function()? loading,
    TResult Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Loading value) loading,
    required TResult Function(_EditionMode value) editionMode,
    required TResult Function(_SeeMode value) seeMode,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_EditionMode value)? editionMode,
    TResult? Function(_SeeMode value)? seeMode,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Loading value)? loading,
    TResult Function(_EditionMode value)? editionMode,
    TResult Function(_SeeMode value)? seeMode,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainingDetailStateCopyWith<$Res> {
  factory $TrainingDetailStateCopyWith(
    TrainingDetailState value,
    $Res Function(TrainingDetailState) then,
  ) = _$TrainingDetailStateCopyWithImpl<$Res, TrainingDetailState>;
}

/// @nodoc
class _$TrainingDetailStateCopyWithImpl<$Res, $Val extends TrainingDetailState>
    implements $TrainingDetailStateCopyWith<$Res> {
  _$TrainingDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$EmptyImplCopyWith<$Res> {
  factory _$$EmptyImplCopyWith(
    _$EmptyImpl value,
    $Res Function(_$EmptyImpl) then,
  ) = __$$EmptyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EmptyImplCopyWithImpl<$Res>
    extends _$TrainingDetailStateCopyWithImpl<$Res, _$EmptyImpl>
    implements _$$EmptyImplCopyWith<$Res> {
  __$$EmptyImplCopyWithImpl(
    _$EmptyImpl _value,
    $Res Function(_$EmptyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$EmptyImpl implements _Empty {
  const _$EmptyImpl();

  @override
  String toString() {
    return 'TrainingDetailState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$EmptyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function() loading,
    required TResult Function(
      TrainingPlan plan,
      List<ExerciseDetailData> exercises,
    )
    editionMode,
    required TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )
    seeMode,
    required TResult Function(String message) error,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function()? loading,
    TResult? Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult? Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult? Function(String message)? error,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function()? loading,
    TResult Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Loading value) loading,
    required TResult Function(_EditionMode value) editionMode,
    required TResult Function(_SeeMode value) seeMode,
    required TResult Function(_Error value) error,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_EditionMode value)? editionMode,
    TResult? Function(_SeeMode value)? seeMode,
    TResult? Function(_Error value)? error,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Loading value)? loading,
    TResult Function(_EditionMode value)? editionMode,
    TResult Function(_SeeMode value)? seeMode,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class _Empty implements TrainingDetailState {
  const factory _Empty() = _$EmptyImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
    _$LoadingImpl value,
    $Res Function(_$LoadingImpl) then,
  ) = __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$TrainingDetailStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
    _$LoadingImpl _value,
    $Res Function(_$LoadingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'TrainingDetailState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function() loading,
    required TResult Function(
      TrainingPlan plan,
      List<ExerciseDetailData> exercises,
    )
    editionMode,
    required TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )
    seeMode,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function()? loading,
    TResult? Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult? Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function()? loading,
    TResult Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Loading value) loading,
    required TResult Function(_EditionMode value) editionMode,
    required TResult Function(_SeeMode value) seeMode,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_EditionMode value)? editionMode,
    TResult? Function(_SeeMode value)? seeMode,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Loading value)? loading,
    TResult Function(_EditionMode value)? editionMode,
    TResult Function(_SeeMode value)? seeMode,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements TrainingDetailState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$EditionModeImplCopyWith<$Res> {
  factory _$$EditionModeImplCopyWith(
    _$EditionModeImpl value,
    $Res Function(_$EditionModeImpl) then,
  ) = __$$EditionModeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({TrainingPlan plan, List<ExerciseDetailData> exercises});

  $TrainingPlanCopyWith<$Res> get plan;
}

/// @nodoc
class __$$EditionModeImplCopyWithImpl<$Res>
    extends _$TrainingDetailStateCopyWithImpl<$Res, _$EditionModeImpl>
    implements _$$EditionModeImplCopyWith<$Res> {
  __$$EditionModeImplCopyWithImpl(
    _$EditionModeImpl _value,
    $Res Function(_$EditionModeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? plan = null, Object? exercises = null}) {
    return _then(
      _$EditionModeImpl(
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as TrainingPlan,
        exercises: null == exercises
            ? _value._exercises
            : exercises // ignore: cast_nullable_to_non_nullable
                  as List<ExerciseDetailData>,
      ),
    );
  }

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainingPlanCopyWith<$Res> get plan {
    return $TrainingPlanCopyWith<$Res>(_value.plan, (value) {
      return _then(_value.copyWith(plan: value));
    });
  }
}

/// @nodoc

class _$EditionModeImpl implements _EditionMode {
  const _$EditionModeImpl({
    required this.plan,
    required final List<ExerciseDetailData> exercises,
  }) : _exercises = exercises;

  @override
  final TrainingPlan plan;
  final List<ExerciseDetailData> _exercises;
  @override
  List<ExerciseDetailData> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  String toString() {
    return 'TrainingDetailState.editionMode(plan: $plan, exercises: $exercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EditionModeImpl &&
            (identical(other.plan, plan) || other.plan == plan) &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    plan,
    const DeepCollectionEquality().hash(_exercises),
  );

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EditionModeImplCopyWith<_$EditionModeImpl> get copyWith =>
      __$$EditionModeImplCopyWithImpl<_$EditionModeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function() loading,
    required TResult Function(
      TrainingPlan plan,
      List<ExerciseDetailData> exercises,
    )
    editionMode,
    required TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )
    seeMode,
    required TResult Function(String message) error,
  }) {
    return editionMode(plan, exercises);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function()? loading,
    TResult? Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult? Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult? Function(String message)? error,
  }) {
    return editionMode?.call(plan, exercises);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function()? loading,
    TResult Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (editionMode != null) {
      return editionMode(plan, exercises);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Loading value) loading,
    required TResult Function(_EditionMode value) editionMode,
    required TResult Function(_SeeMode value) seeMode,
    required TResult Function(_Error value) error,
  }) {
    return editionMode(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_EditionMode value)? editionMode,
    TResult? Function(_SeeMode value)? seeMode,
    TResult? Function(_Error value)? error,
  }) {
    return editionMode?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Loading value)? loading,
    TResult Function(_EditionMode value)? editionMode,
    TResult Function(_SeeMode value)? seeMode,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (editionMode != null) {
      return editionMode(this);
    }
    return orElse();
  }
}

abstract class _EditionMode implements TrainingDetailState {
  const factory _EditionMode({
    required final TrainingPlan plan,
    required final List<ExerciseDetailData> exercises,
  }) = _$EditionModeImpl;

  TrainingPlan get plan;
  List<ExerciseDetailData> get exercises;

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EditionModeImplCopyWith<_$EditionModeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SeeModeImplCopyWith<$Res> {
  factory _$$SeeModeImplCopyWith(
    _$SeeModeImpl value,
    $Res Function(_$SeeModeImpl) then,
  ) = __$$SeeModeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    TrainingPlan plan,
    TrainingSession? session,
    List<ExerciseDetailData> exercises,
  });

  $TrainingPlanCopyWith<$Res> get plan;
  $TrainingSessionCopyWith<$Res>? get session;
}

/// @nodoc
class __$$SeeModeImplCopyWithImpl<$Res>
    extends _$TrainingDetailStateCopyWithImpl<$Res, _$SeeModeImpl>
    implements _$$SeeModeImplCopyWith<$Res> {
  __$$SeeModeImplCopyWithImpl(
    _$SeeModeImpl _value,
    $Res Function(_$SeeModeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? session = freezed,
    Object? exercises = null,
  }) {
    return _then(
      _$SeeModeImpl(
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as TrainingPlan,
        session: freezed == session
            ? _value.session
            : session // ignore: cast_nullable_to_non_nullable
                  as TrainingSession?,
        exercises: null == exercises
            ? _value._exercises
            : exercises // ignore: cast_nullable_to_non_nullable
                  as List<ExerciseDetailData>,
      ),
    );
  }

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainingPlanCopyWith<$Res> get plan {
    return $TrainingPlanCopyWith<$Res>(_value.plan, (value) {
      return _then(_value.copyWith(plan: value));
    });
  }

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TrainingSessionCopyWith<$Res>? get session {
    if (_value.session == null) {
      return null;
    }

    return $TrainingSessionCopyWith<$Res>(_value.session!, (value) {
      return _then(_value.copyWith(session: value));
    });
  }
}

/// @nodoc

class _$SeeModeImpl implements _SeeMode {
  const _$SeeModeImpl({
    required this.plan,
    this.session,
    required final List<ExerciseDetailData> exercises,
  }) : _exercises = exercises;

  @override
  final TrainingPlan plan;
  @override
  final TrainingSession? session;
  final List<ExerciseDetailData> _exercises;
  @override
  List<ExerciseDetailData> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  String toString() {
    return 'TrainingDetailState.seeMode(plan: $plan, session: $session, exercises: $exercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeeModeImpl &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.session, session) || other.session == session) &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    plan,
    session,
    const DeepCollectionEquality().hash(_exercises),
  );

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SeeModeImplCopyWith<_$SeeModeImpl> get copyWith =>
      __$$SeeModeImplCopyWithImpl<_$SeeModeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function() loading,
    required TResult Function(
      TrainingPlan plan,
      List<ExerciseDetailData> exercises,
    )
    editionMode,
    required TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )
    seeMode,
    required TResult Function(String message) error,
  }) {
    return seeMode(plan, session, exercises);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function()? loading,
    TResult? Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult? Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult? Function(String message)? error,
  }) {
    return seeMode?.call(plan, session, exercises);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function()? loading,
    TResult Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (seeMode != null) {
      return seeMode(plan, session, exercises);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Loading value) loading,
    required TResult Function(_EditionMode value) editionMode,
    required TResult Function(_SeeMode value) seeMode,
    required TResult Function(_Error value) error,
  }) {
    return seeMode(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_EditionMode value)? editionMode,
    TResult? Function(_SeeMode value)? seeMode,
    TResult? Function(_Error value)? error,
  }) {
    return seeMode?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Loading value)? loading,
    TResult Function(_EditionMode value)? editionMode,
    TResult Function(_SeeMode value)? seeMode,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (seeMode != null) {
      return seeMode(this);
    }
    return orElse();
  }
}

abstract class _SeeMode implements TrainingDetailState {
  const factory _SeeMode({
    required final TrainingPlan plan,
    final TrainingSession? session,
    required final List<ExerciseDetailData> exercises,
  }) = _$SeeModeImpl;

  TrainingPlan get plan;
  TrainingSession? get session;
  List<ExerciseDetailData> get exercises;

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SeeModeImplCopyWith<_$SeeModeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
    _$ErrorImpl value,
    $Res Function(_$ErrorImpl) then,
  ) = __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$TrainingDetailStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ErrorImpl(
        null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'TrainingDetailState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function() loading,
    required TResult Function(
      TrainingPlan plan,
      List<ExerciseDetailData> exercises,
    )
    editionMode,
    required TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )
    seeMode,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? empty,
    TResult? Function()? loading,
    TResult? Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult? Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function()? loading,
    TResult Function(TrainingPlan plan, List<ExerciseDetailData> exercises)?
    editionMode,
    TResult Function(
      TrainingPlan plan,
      TrainingSession? session,
      List<ExerciseDetailData> exercises,
    )?
    seeMode,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Empty value) empty,
    required TResult Function(_Loading value) loading,
    required TResult Function(_EditionMode value) editionMode,
    required TResult Function(_SeeMode value) seeMode,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_EditionMode value)? editionMode,
    TResult? Function(_SeeMode value)? seeMode,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Empty value)? empty,
    TResult Function(_Loading value)? loading,
    TResult Function(_EditionMode value)? editionMode,
    TResult Function(_SeeMode value)? seeMode,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements TrainingDetailState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of TrainingDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
