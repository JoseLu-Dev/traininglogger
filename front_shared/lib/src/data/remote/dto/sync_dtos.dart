import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_dtos.freezed.dart';
part 'sync_dtos.g.dart';

// Pull request
@freezed
class SyncPullRequestDto with _$SyncPullRequestDto {
  const factory SyncPullRequestDto({
    required List<String> entityTypes,
    DateTime? lastSyncTime,
  }) = _SyncPullRequestDto;

  factory SyncPullRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SyncPullRequestDtoFromJson(json);
}

// Pull response
@freezed
class SyncPullResponseDto with _$SyncPullResponseDto {
  const factory SyncPullResponseDto({
    required Map<String, List<Map<String, dynamic>>> entities,
    required DateTime syncTimestamp,
    required int totalEntities,
  }) = _SyncPullResponseDto;

  factory SyncPullResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SyncPullResponseDtoFromJson(json);
}

// EntityStats removed - backend returns simple totalEntities count

// Push request
@freezed
class SyncPushRequestDto with _$SyncPushRequestDto {
  const factory SyncPushRequestDto({
    required Map<String, List<Map<String, dynamic>>> entities,
  }) = _SyncPushRequestDto;

  factory SyncPushRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SyncPushRequestDtoFromJson(json);
}

// Push response
@Freezed(toJson: true)
class SyncPushResponseDto with _$SyncPushResponseDto {
  const factory SyncPushResponseDto({
    required int successCount,
    required int failureCount,
    required List<EntityFailure> failures,
    required DateTime syncTimestamp,
  }) = _SyncPushResponseDto;

  factory SyncPushResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SyncPushResponseDtoFromJson(json);
}

// SyncSuccessDto removed - backend only returns counts, not success details
// SyncSummary removed - counts are top-level fields

@Freezed(toJson: true)
class EntityFailure with _$EntityFailure {
  const factory EntityFailure({
    required String entityType,
    required String entityId,
    required List<ValidationError> errors,
  }) = _EntityFailure;

  factory EntityFailure.fromJson(Map<String, dynamic> json) =>
      _$EntityFailureFromJson(json);
}

@freezed
class ValidationError with _$ValidationError {
  const factory ValidationError({
    required String field,
    required String code,     // ADDED: Backend includes error code
    required String message,
  }) = _ValidationError;

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);
}
