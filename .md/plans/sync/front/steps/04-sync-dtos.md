# Step 04: Sync DTOs and API Service

## Goal
Create all DTOs for sync API communication and implement the SyncApiService.

## Tasks

### 1. Create sync DTOs
Create `lib/src/data/remote/dto/sync_dtos.dart`:
```dart
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
@freezed
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

@freezed
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
```

### 2. Create SyncApiService
Create `lib/src/data/remote/sync_api_service.dart`:
```dart
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'dto/sync_dtos.dart';

class SyncApiService {
  final ApiClient _apiClient;

  SyncApiService(this._apiClient);

  /// Pull changes from server
  Future<SyncPullResponseDto> pull({
    required List<String> entityTypes,
    DateTime? lastSyncTime,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'entityTypes': entityTypes,
      };

      if (lastSyncTime != null) {
        queryParams['lastSyncTime'] = lastSyncTime.toIso8601String();
      }

      final response = await _apiClient.dio.get(
        '/api/v1/sync/pull',
        queryParameters: queryParams,
      );

      return SyncPullResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Push local changes to server
  Future<SyncPushResponseDto> push(SyncPushRequestDto request) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/sync/push',
        data: request.toJson(),
      );

      return SyncPushResponseDto.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Connection timeout');
    } else if (e.type == DioExceptionType.connectionError) {
      return NetworkException('No internet connection');
    } else if (e.response?.statusCode == 401) {
      return UnauthorizedException('Unauthorized');
    } else if (e.response?.statusCode == 400) {
      return ValidationException('Invalid request: ${e.response?.data}');
    } else if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
      return ServerException('Server error: ${e.response?.statusCode}');
    }
    return NetworkException('Network error: ${e.message}');
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);

  @override
  String toString() => 'ServerException: $message';
}
```

### 3. Create sync API provider
Add to `lib/src/providers/network_providers.dart`:
```dart
import '../data/remote/sync_api_service.dart';

final syncApiServiceProvider = Provider<SyncApiService>((ref) {
  return SyncApiService(ref.watch(apiClientProvider));
});
```

### 4. Run code generation
```bash
cd front_shared
dart run build_runner build --delete-conflicting-outputs
```

## Success Criteria
- ✅ All sync DTOs created with freezed and json_serializable
- ✅ SyncApiService implemented with pull and push methods
- ✅ Error handling for network, validation, and server errors
- ✅ Sync API provider defined
- ✅ Code generation successful

## Estimated Time
1.5 hours

## Next Step
05-entity-registry.md - Create generic entity registry for DAO/mapper management
