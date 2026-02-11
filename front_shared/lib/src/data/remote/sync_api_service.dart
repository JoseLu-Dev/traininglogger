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
