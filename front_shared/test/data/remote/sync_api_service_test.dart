import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:front_shared/src/data/remote/api_client.dart';
import 'package:front_shared/src/data/remote/sync_api_service.dart';
import 'package:front_shared/src/data/remote/dto/sync_dtos.dart';

import 'sync_api_service_test.mocks.dart';

@GenerateMocks([ApiClient, Dio])
void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late SyncApiService syncApiService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(mockApiClient.dio).thenReturn(mockDio);
    syncApiService = SyncApiService(mockApiClient);
  });

  group('SyncApiService', () {
    group('pull', () {
      test('should make GET request to correct endpoint with entity types', () async {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final responseData = {
          'entities': {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1'}
            ],
          },
          'syncTimestamp': syncTimestamp.toIso8601String(),
          'totalEntities': 1,
        };
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
            ));

        // act
        await syncApiService.pull(
          entityTypes: ['TrainingPlan'],
          lastSyncTime: null,
        );

        // assert
        verify(mockDio.get(
          '/api/v1/sync/pull',
          queryParameters: {
            'entityTypes': ['TrainingPlan'],
          },
        )).called(1);
      });

      test('should include lastSyncTime in query params when provided', () async {
        // arrange
        final lastSyncTime = DateTime(2024, 1, 1, 10, 0, 0);
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final responseData = {
          'entities': <String, List<Map<String, dynamic>>>{},
          'syncTimestamp': syncTimestamp.toIso8601String(),
          'totalEntities': 0,
        };
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
            ));

        // act
        await syncApiService.pull(
          entityTypes: ['Exercise'],
          lastSyncTime: lastSyncTime,
        );

        // assert
        verify(mockDio.get(
          '/api/v1/sync/pull',
          queryParameters: {
            'entityTypes': ['Exercise'],
            'lastSyncTime': lastSyncTime.toIso8601String(),
          },
        )).called(1);
      });

      test('should return SyncPullResponseDto on success', () async {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final responseData = {
          'entities': {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1'}
            ],
          },
          'syncTimestamp': syncTimestamp.toIso8601String(),
          'totalEntities': 1,
        };
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
            ));

        // act
        final result = await syncApiService.pull(
          entityTypes: ['TrainingPlan'],
          lastSyncTime: null,
        );

        // assert
        expect(result, isA<SyncPullResponseDto>());
        expect(result.totalEntities, 1);
        expect(result.syncTimestamp, syncTimestamp);
      });

      test('should throw NetworkException on connection timeout', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          type: DioExceptionType.connectionTimeout,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['TrainingPlan'],
            lastSyncTime: null,
          ),
          throwsA(isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Connection timeout',
          )),
        );
      });

      test('should throw NetworkException on receive timeout', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          type: DioExceptionType.receiveTimeout,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['TrainingPlan'],
            lastSyncTime: null,
          ),
          throwsA(isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Connection timeout',
          )),
        );
      });

      test('should throw NetworkException on connection error', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          type: DioExceptionType.connectionError,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['TrainingPlan'],
            lastSyncTime: null,
          ),
          throwsA(isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'No internet connection',
          )),
        );
      });

      test('should throw UnauthorizedException on 401 response', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['TrainingPlan'],
            lastSyncTime: null,
          ),
          throwsA(isA<UnauthorizedException>().having(
            (e) => e.message,
            'message',
            'Unauthorized',
          )),
        );
      });

      test('should throw ValidationException on 400 response', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          response: Response(
            statusCode: 400,
            data: 'Invalid entity types',
            requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['InvalidType'],
            lastSyncTime: null,
          ),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ServerException on 500 response', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['TrainingPlan'],
            lastSyncTime: null,
          ),
          throwsA(isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Server error: 500'),
          )),
        );
      });

      test('should throw ServerException on 503 response', () async {
        // arrange
        when(mockDio.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          response: Response(
            statusCode: 503,
            requestOptions: RequestOptions(path: '/api/v1/sync/pull'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.pull(
            entityTypes: ['TrainingPlan'],
            lastSyncTime: null,
          ),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('push', () {
      test('should make POST request to correct endpoint with request data', () async {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final request = SyncPushRequestDto(
          entities: {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1', 'isDirty': true}
            ],
          },
        );
        final responseData = {
          'successCount': 1,
          'failureCount': 0,
          'failures': [],
          'syncTimestamp': syncTimestamp.toIso8601String(),
        };
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/v1/sync/push'),
            ));

        // act
        await syncApiService.push(request);

        // assert
        verify(mockDio.post(
          '/api/v1/sync/push',
          data: request.toJson(),
        )).called(1);
      });

      test('should return SyncPushResponseDto on success', () async {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final request = SyncPushRequestDto(
          entities: {
            'Exercise': [
              {'id': '2', 'name': 'Exercise 1'}
            ],
          },
        );
        final responseData = {
          'successCount': 1,
          'failureCount': 0,
          'failures': [],
          'syncTimestamp': syncTimestamp.toIso8601String(),
        };
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/v1/sync/push'),
            ));

        // act
        final result = await syncApiService.push(request);

        // assert
        expect(result, isA<SyncPushResponseDto>());
        expect(result.successCount, 1);
        expect(result.failureCount, 0);
        expect(result.failures, isEmpty);
      });

      test('should handle response with failures', () async {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final request = SyncPushRequestDto(
          entities: {
            'TrainingPlan': [
              {'id': '1', 'name': ''}
            ],
          },
        );
        final responseData = {
          'successCount': 0,
          'failureCount': 1,
          'failures': [
            {
              'entityType': 'TrainingPlan',
              'entityId': '1',
              'errors': [
                {
                  'field': 'name',
                  'code': 'required',
                  'message': 'Name is required',
                },
              ],
            },
          ],
          'syncTimestamp': syncTimestamp.toIso8601String(),
        };
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/api/v1/sync/push'),
            ));

        // act
        final result = await syncApiService.push(request);

        // assert
        expect(result.successCount, 0);
        expect(result.failureCount, 1);
        expect(result.failures.length, 1);
        expect(result.failures[0].entityType, 'TrainingPlan');
        expect(result.failures[0].errors[0].code, 'required');
      });

      test('should throw NetworkException on connection timeout', () async {
        // arrange
        final request = SyncPushRequestDto(
          entities: {},
        );
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          type: DioExceptionType.connectionTimeout,
        ));

        // act & assert
        expect(
          () => syncApiService.push(request),
          throwsA(isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Connection timeout',
          )),
        );
      });

      test('should throw NetworkException on connection error', () async {
        // arrange
        final request = SyncPushRequestDto(
          entities: {},
        );
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          type: DioExceptionType.connectionError,
        ));

        // act & assert
        expect(
          () => syncApiService.push(request),
          throwsA(isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'No internet connection',
          )),
        );
      });

      test('should throw UnauthorizedException on 401 response', () async {
        // arrange
        final request = SyncPushRequestDto(
          entities: {},
        );
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.push(request),
          throwsA(isA<UnauthorizedException>()),
        );
      });

      test('should throw ValidationException on 400 response', () async {
        // arrange
        final request = SyncPushRequestDto(
          entities: {},
        );
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          response: Response(
            statusCode: 400,
            data: 'Invalid data',
            requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.push(request),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ServerException on 500 response', () async {
        // arrange
        final request = SyncPushRequestDto(
          entities: {},
        );
        when(mockDio.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/api/v1/sync/push'),
          ),
          type: DioExceptionType.badResponse,
        ));

        // act & assert
        expect(
          () => syncApiService.push(request),
          throwsA(isA<ServerException>()),
        );
      });
    });
  });

  group('Exception Classes', () {
    group('UnauthorizedException', () {
      test('should create exception with message', () {
        // arrange
        const message = 'User not authenticated';

        // act
        final exception = UnauthorizedException(message);

        // assert
        expect(exception.message, message);
      });

      test('should have correct toString format', () {
        // arrange
        const message = 'Unauthorized access';

        // act
        final exception = UnauthorizedException(message);

        // assert
        expect(exception.toString(), 'UnauthorizedException: Unauthorized access');
      });
    });

    group('ValidationException', () {
      test('should create exception with message', () {
        // arrange
        const message = 'Invalid input data';

        // act
        final exception = ValidationException(message);

        // assert
        expect(exception.message, message);
      });

      test('should have correct toString format', () {
        // arrange
        const message = 'Validation failed';

        // act
        final exception = ValidationException(message);

        // assert
        expect(exception.toString(), 'ValidationException: Validation failed');
      });
    });

    group('ServerException', () {
      test('should create exception with message', () {
        // arrange
        const message = 'Internal server error';

        // act
        final exception = ServerException(message);

        // assert
        expect(exception.message, message);
      });

      test('should have correct toString format', () {
        // arrange
        const message = 'Server error: 500';

        // act
        final exception = ServerException(message);

        // assert
        expect(exception.toString(), 'ServerException: Server error: 500');
      });
    });
  });
}
