// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SyncState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String phase) syncing,
    required TResult Function(SyncResult result) completed,
    required TResult Function(String message) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String phase)? syncing,
    TResult? Function(SyncResult result)? completed,
    TResult? Function(String message)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String phase)? syncing,
    TResult Function(SyncResult result)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStateCopyWith<$Res> {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) then) =
      _$SyncStateCopyWithImpl<$Res, SyncState>;
}

/// @nodoc
class _$SyncStateCopyWithImpl<$Res, $Val extends SyncState>
    implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
    _$IdleImpl value,
    $Res Function(_$IdleImpl) then,
  ) = __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
    : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'SyncState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String phase) syncing,
    required TResult Function(SyncResult result) completed,
    required TResult Function(String message) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String phase)? syncing,
    TResult? Function(SyncResult result)? completed,
    TResult? Function(String message)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String phase)? syncing,
    TResult Function(SyncResult result)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements SyncState {
  const factory _Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$SyncingImplCopyWith<$Res> {
  factory _$$SyncingImplCopyWith(
    _$SyncingImpl value,
    $Res Function(_$SyncingImpl) then,
  ) = __$$SyncingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String phase});
}

/// @nodoc
class __$$SyncingImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncingImpl>
    implements _$$SyncingImplCopyWith<$Res> {
  __$$SyncingImplCopyWithImpl(
    _$SyncingImpl _value,
    $Res Function(_$SyncingImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? phase = null}) {
    return _then(
      _$SyncingImpl(
        phase: null == phase
            ? _value.phase
            : phase // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SyncingImpl implements _Syncing {
  const _$SyncingImpl({required this.phase});

  @override
  final String phase;

  @override
  String toString() {
    return 'SyncState.syncing(phase: $phase)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncingImpl &&
            (identical(other.phase, phase) || other.phase == phase));
  }

  @override
  int get hashCode => Object.hash(runtimeType, phase);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncingImplCopyWith<_$SyncingImpl> get copyWith =>
      __$$SyncingImplCopyWithImpl<_$SyncingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String phase) syncing,
    required TResult Function(SyncResult result) completed,
    required TResult Function(String message) error,
  }) {
    return syncing(phase);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String phase)? syncing,
    TResult? Function(SyncResult result)? completed,
    TResult? Function(String message)? error,
  }) {
    return syncing?.call(phase);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String phase)? syncing,
    TResult Function(SyncResult result)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing(phase);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return syncing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return syncing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (syncing != null) {
      return syncing(this);
    }
    return orElse();
  }
}

abstract class _Syncing implements SyncState {
  const factory _Syncing({required final String phase}) = _$SyncingImpl;

  String get phase;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncingImplCopyWith<_$SyncingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompletedImplCopyWith<$Res> {
  factory _$$CompletedImplCopyWith(
    _$CompletedImpl value,
    $Res Function(_$CompletedImpl) then,
  ) = __$$CompletedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({SyncResult result});

  $SyncResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$CompletedImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$CompletedImpl>
    implements _$$CompletedImplCopyWith<$Res> {
  __$$CompletedImplCopyWithImpl(
    _$CompletedImpl _value,
    $Res Function(_$CompletedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? result = null}) {
    return _then(
      _$CompletedImpl(
        null == result
            ? _value.result
            : result // ignore: cast_nullable_to_non_nullable
                  as SyncResult,
      ),
    );
  }

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SyncResultCopyWith<$Res> get result {
    return $SyncResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$CompletedImpl implements _Completed {
  const _$CompletedImpl(this.result);

  @override
  final SyncResult result;

  @override
  String toString() {
    return 'SyncState.completed(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompletedImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompletedImplCopyWith<_$CompletedImpl> get copyWith =>
      __$$CompletedImplCopyWithImpl<_$CompletedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String phase) syncing,
    required TResult Function(SyncResult result) completed,
    required TResult Function(String message) error,
  }) {
    return completed(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String phase)? syncing,
    TResult? Function(SyncResult result)? completed,
    TResult? Function(String message)? error,
  }) {
    return completed?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String phase)? syncing,
    TResult Function(SyncResult result)? completed,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class _Completed implements SyncState {
  const factory _Completed(final SyncResult result) = _$CompletedImpl;

  SyncResult get result;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompletedImplCopyWith<_$CompletedImpl> get copyWith =>
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
    extends _$SyncStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
    _$ErrorImpl _value,
    $Res Function(_$ErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncState
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
    return 'SyncState.error(message: $message)';
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

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String phase) syncing,
    required TResult Function(SyncResult result) completed,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String phase)? syncing,
    TResult? Function(SyncResult result)? completed,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String phase)? syncing,
    TResult Function(SyncResult result)? completed,
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
    required TResult Function(_Idle value) idle,
    required TResult Function(_Syncing value) syncing,
    required TResult Function(_Completed value) completed,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Syncing value)? syncing,
    TResult? Function(_Completed value)? completed,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Syncing value)? syncing,
    TResult Function(_Completed value)? completed,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements SyncState {
  const factory _Error(final String message) = _$ErrorImpl;

  String get message;

  /// Create a copy of SyncState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SyncResult {
  DateTime get timestamp => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pullCount, int pushCount, DateTime timestamp)
    success,
    required TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )
    partialSuccess,
    required TResult Function(String message, Object? error, DateTime timestamp)
    failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pullCount, int pushCount, DateTime timestamp)?
    success,
    TResult? Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult? Function(String message, Object? error, DateTime timestamp)?
    failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pullCount, int pushCount, DateTime timestamp)? success,
    TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult Function(String message, Object? error, DateTime timestamp)?
    failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success value) success,
    required TResult Function(_PartialSuccess value) partialSuccess,
    required TResult Function(_Failure value) failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success value)? success,
    TResult? Function(_PartialSuccess value)? partialSuccess,
    TResult? Function(_Failure value)? failure,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success value)? success,
    TResult Function(_PartialSuccess value)? partialSuccess,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncResultCopyWith<SyncResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncResultCopyWith<$Res> {
  factory $SyncResultCopyWith(
    SyncResult value,
    $Res Function(SyncResult) then,
  ) = _$SyncResultCopyWithImpl<$Res, SyncResult>;
  @useResult
  $Res call({DateTime timestamp});
}

/// @nodoc
class _$SyncResultCopyWithImpl<$Res, $Val extends SyncResult>
    implements $SyncResultCopyWith<$Res> {
  _$SyncResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? timestamp = null}) {
    return _then(
      _value.copyWith(
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res>
    implements $SyncResultCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
    _$SuccessImpl value,
    $Res Function(_$SuccessImpl) then,
  ) = __$$SuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int pullCount, int pushCount, DateTime timestamp});
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$SyncResultCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
    _$SuccessImpl _value,
    $Res Function(_$SuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pullCount = null,
    Object? pushCount = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$SuccessImpl(
        pullCount: null == pullCount
            ? _value.pullCount
            : pullCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pushCount: null == pushCount
            ? _value.pushCount
            : pushCount // ignore: cast_nullable_to_non_nullable
                  as int,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl({
    required this.pullCount,
    required this.pushCount,
    required this.timestamp,
  });

  @override
  final int pullCount;
  @override
  final int pushCount;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SyncResult.success(pullCount: $pullCount, pushCount: $pushCount, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            (identical(other.pullCount, pullCount) ||
                other.pullCount == pullCount) &&
            (identical(other.pushCount, pushCount) ||
                other.pushCount == pushCount) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(runtimeType, pullCount, pushCount, timestamp);

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pullCount, int pushCount, DateTime timestamp)
    success,
    required TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )
    partialSuccess,
    required TResult Function(String message, Object? error, DateTime timestamp)
    failure,
  }) {
    return success(pullCount, pushCount, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pullCount, int pushCount, DateTime timestamp)?
    success,
    TResult? Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult? Function(String message, Object? error, DateTime timestamp)?
    failure,
  }) {
    return success?.call(pullCount, pushCount, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pullCount, int pushCount, DateTime timestamp)? success,
    TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult Function(String message, Object? error, DateTime timestamp)?
    failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(pullCount, pushCount, timestamp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success value) success,
    required TResult Function(_PartialSuccess value) partialSuccess,
    required TResult Function(_Failure value) failure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success value)? success,
    TResult? Function(_PartialSuccess value)? partialSuccess,
    TResult? Function(_Failure value)? failure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success value)? success,
    TResult Function(_PartialSuccess value)? partialSuccess,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements SyncResult {
  const factory _Success({
    required final int pullCount,
    required final int pushCount,
    required final DateTime timestamp,
  }) = _$SuccessImpl;

  int get pullCount;
  int get pushCount;
  @override
  DateTime get timestamp;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PartialSuccessImplCopyWith<$Res>
    implements $SyncResultCopyWith<$Res> {
  factory _$$PartialSuccessImplCopyWith(
    _$PartialSuccessImpl value,
    $Res Function(_$PartialSuccessImpl) then,
  ) = __$$PartialSuccessImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int pullCount,
    int pushSuccessCount,
    int pushFailureCount,
    List<EntityFailure> failures,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$PartialSuccessImplCopyWithImpl<$Res>
    extends _$SyncResultCopyWithImpl<$Res, _$PartialSuccessImpl>
    implements _$$PartialSuccessImplCopyWith<$Res> {
  __$$PartialSuccessImplCopyWithImpl(
    _$PartialSuccessImpl _value,
    $Res Function(_$PartialSuccessImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pullCount = null,
    Object? pushSuccessCount = null,
    Object? pushFailureCount = null,
    Object? failures = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$PartialSuccessImpl(
        pullCount: null == pullCount
            ? _value.pullCount
            : pullCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pushSuccessCount: null == pushSuccessCount
            ? _value.pushSuccessCount
            : pushSuccessCount // ignore: cast_nullable_to_non_nullable
                  as int,
        pushFailureCount: null == pushFailureCount
            ? _value.pushFailureCount
            : pushFailureCount // ignore: cast_nullable_to_non_nullable
                  as int,
        failures: null == failures
            ? _value._failures
            : failures // ignore: cast_nullable_to_non_nullable
                  as List<EntityFailure>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$PartialSuccessImpl implements _PartialSuccess {
  const _$PartialSuccessImpl({
    required this.pullCount,
    required this.pushSuccessCount,
    required this.pushFailureCount,
    required final List<EntityFailure> failures,
    required this.timestamp,
  }) : _failures = failures;

  @override
  final int pullCount;
  @override
  final int pushSuccessCount;
  @override
  final int pushFailureCount;
  final List<EntityFailure> _failures;
  @override
  List<EntityFailure> get failures {
    if (_failures is EqualUnmodifiableListView) return _failures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_failures);
  }

  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SyncResult.partialSuccess(pullCount: $pullCount, pushSuccessCount: $pushSuccessCount, pushFailureCount: $pushFailureCount, failures: $failures, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartialSuccessImpl &&
            (identical(other.pullCount, pullCount) ||
                other.pullCount == pullCount) &&
            (identical(other.pushSuccessCount, pushSuccessCount) ||
                other.pushSuccessCount == pushSuccessCount) &&
            (identical(other.pushFailureCount, pushFailureCount) ||
                other.pushFailureCount == pushFailureCount) &&
            const DeepCollectionEquality().equals(other._failures, _failures) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    pullCount,
    pushSuccessCount,
    pushFailureCount,
    const DeepCollectionEquality().hash(_failures),
    timestamp,
  );

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartialSuccessImplCopyWith<_$PartialSuccessImpl> get copyWith =>
      __$$PartialSuccessImplCopyWithImpl<_$PartialSuccessImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pullCount, int pushCount, DateTime timestamp)
    success,
    required TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )
    partialSuccess,
    required TResult Function(String message, Object? error, DateTime timestamp)
    failure,
  }) {
    return partialSuccess(
      pullCount,
      pushSuccessCount,
      pushFailureCount,
      failures,
      timestamp,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pullCount, int pushCount, DateTime timestamp)?
    success,
    TResult? Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult? Function(String message, Object? error, DateTime timestamp)?
    failure,
  }) {
    return partialSuccess?.call(
      pullCount,
      pushSuccessCount,
      pushFailureCount,
      failures,
      timestamp,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pullCount, int pushCount, DateTime timestamp)? success,
    TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult Function(String message, Object? error, DateTime timestamp)?
    failure,
    required TResult orElse(),
  }) {
    if (partialSuccess != null) {
      return partialSuccess(
        pullCount,
        pushSuccessCount,
        pushFailureCount,
        failures,
        timestamp,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success value) success,
    required TResult Function(_PartialSuccess value) partialSuccess,
    required TResult Function(_Failure value) failure,
  }) {
    return partialSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success value)? success,
    TResult? Function(_PartialSuccess value)? partialSuccess,
    TResult? Function(_Failure value)? failure,
  }) {
    return partialSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success value)? success,
    TResult Function(_PartialSuccess value)? partialSuccess,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (partialSuccess != null) {
      return partialSuccess(this);
    }
    return orElse();
  }
}

abstract class _PartialSuccess implements SyncResult {
  const factory _PartialSuccess({
    required final int pullCount,
    required final int pushSuccessCount,
    required final int pushFailureCount,
    required final List<EntityFailure> failures,
    required final DateTime timestamp,
  }) = _$PartialSuccessImpl;

  int get pullCount;
  int get pushSuccessCount;
  int get pushFailureCount;
  List<EntityFailure> get failures;
  @override
  DateTime get timestamp;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartialSuccessImplCopyWith<_$PartialSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$FailureImplCopyWith<$Res>
    implements $SyncResultCopyWith<$Res> {
  factory _$$FailureImplCopyWith(
    _$FailureImpl value,
    $Res Function(_$FailureImpl) then,
  ) = __$$FailureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, Object? error, DateTime timestamp});
}

/// @nodoc
class __$$FailureImplCopyWithImpl<$Res>
    extends _$SyncResultCopyWithImpl<$Res, _$FailureImpl>
    implements _$$FailureImplCopyWith<$Res> {
  __$$FailureImplCopyWithImpl(
    _$FailureImpl _value,
    $Res Function(_$FailureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? error = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$FailureImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        error: freezed == error ? _value.error : error,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$FailureImpl implements _Failure {
  const _$FailureImpl({
    required this.message,
    required this.error,
    required this.timestamp,
  });

  @override
  final String message;
  @override
  final Object? error;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SyncResult.failure(message: $message, error: $error, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FailureImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    message,
    const DeepCollectionEquality().hash(error),
    timestamp,
  );

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      __$$FailureImplCopyWithImpl<_$FailureImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int pullCount, int pushCount, DateTime timestamp)
    success,
    required TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )
    partialSuccess,
    required TResult Function(String message, Object? error, DateTime timestamp)
    failure,
  }) {
    return failure(message, error, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(int pullCount, int pushCount, DateTime timestamp)?
    success,
    TResult? Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult? Function(String message, Object? error, DateTime timestamp)?
    failure,
  }) {
    return failure?.call(message, error, timestamp);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int pullCount, int pushCount, DateTime timestamp)? success,
    TResult Function(
      int pullCount,
      int pushSuccessCount,
      int pushFailureCount,
      List<EntityFailure> failures,
      DateTime timestamp,
    )?
    partialSuccess,
    TResult Function(String message, Object? error, DateTime timestamp)?
    failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(message, error, timestamp);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Success value) success,
    required TResult Function(_PartialSuccess value) partialSuccess,
    required TResult Function(_Failure value) failure,
  }) {
    return failure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Success value)? success,
    TResult? Function(_PartialSuccess value)? partialSuccess,
    TResult? Function(_Failure value)? failure,
  }) {
    return failure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Success value)? success,
    TResult Function(_PartialSuccess value)? partialSuccess,
    TResult Function(_Failure value)? failure,
    required TResult orElse(),
  }) {
    if (failure != null) {
      return failure(this);
    }
    return orElse();
  }
}

abstract class _Failure implements SyncResult {
  const factory _Failure({
    required final String message,
    required final Object? error,
    required final DateTime timestamp,
  }) = _$FailureImpl;

  String get message;
  Object? get error;
  @override
  DateTime get timestamp;

  /// Create a copy of SyncResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FailureImplCopyWith<_$FailureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$EntityFailure {
  String get entityType => throw _privateConstructorUsedError;
  String get entityId => throw _privateConstructorUsedError;
  List<ValidationError> get errors => throw _privateConstructorUsedError;

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

class _$EntityFailureImpl implements _EntityFailure {
  const _$EntityFailureImpl({
    required this.entityType,
    required this.entityId,
    required final List<ValidationError> errors,
  }) : _errors = errors;

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
}

abstract class _EntityFailure implements EntityFailure {
  const factory _EntityFailure({
    required final String entityType,
    required final String entityId,
    required final List<ValidationError> errors,
  }) = _$EntityFailureImpl;

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

/// @nodoc
mixin _$ValidationError {
  String get field => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

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

class _$ValidationErrorImpl implements _ValidationError {
  const _$ValidationErrorImpl({
    required this.field,
    required this.code,
    required this.message,
  });

  @override
  final String field;
  @override
  final String code;
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
}

abstract class _ValidationError implements ValidationError {
  const factory _ValidationError({
    required final String field,
    required final String code,
    required final String message,
  }) = _$ValidationErrorImpl;

  @override
  String get field;
  @override
  String get code;
  @override
  String get message;

  /// Create a copy of ValidationError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
