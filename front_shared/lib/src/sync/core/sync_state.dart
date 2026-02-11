import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_state.freezed.dart';

@freezed
class SyncState with _$SyncState {
  const factory SyncState.idle() = _Idle;
  const factory SyncState.syncing({required String phase}) = _Syncing;
  const factory SyncState.completed(SyncResult result) = _Completed;
  const factory SyncState.error(String message) = _Error;
}

@freezed
class SyncResult with _$SyncResult {
  const factory SyncResult.success({
    required int pullCount,
    required int pushCount,
    required DateTime timestamp,
  }) = _Success;

  const factory SyncResult.partialSuccess({
    required int pullCount,
    required int pushSuccessCount,
    required int pushFailureCount,
    required List<EntityFailure> failures,
    required DateTime timestamp,
  }) = _PartialSuccess;

  const factory SyncResult.failure({
    required String message,
    required Object? error,
    required DateTime timestamp,
  }) = _Failure;
}

@freezed
class EntityFailure with _$EntityFailure {
  const factory EntityFailure({
    required String entityType,
    required String entityId,
    required List<ValidationError> errors,
  }) = _EntityFailure;
}

@freezed
class ValidationError with _$ValidationError {
  const factory ValidationError({
    required String field,
    required String code,
    required String message,
  }) = _ValidationError;
}
