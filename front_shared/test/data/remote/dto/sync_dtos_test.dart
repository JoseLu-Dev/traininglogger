import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/data/remote/dto/sync_dtos.dart';

void main() {
  group('SyncPullRequestDto', () {
    group('Serialization', () {
      test('should serialize to JSON with lastSyncTime', () {
        // arrange
        final lastSyncTime = DateTime(2024, 1, 1, 12, 0, 0);
        final dto = SyncPullRequestDto(
          entityTypes: ['TrainingPlan', 'Exercise'],
          lastSyncTime: lastSyncTime,
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['entityTypes'], ['TrainingPlan', 'Exercise']);
        expect(json['lastSyncTime'], lastSyncTime.toIso8601String());
      });

      test('should serialize to JSON without lastSyncTime', () {
        // arrange
        final dto = SyncPullRequestDto(
          entityTypes: ['TrainingPlan'],
          lastSyncTime: null,
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['entityTypes'], ['TrainingPlan']);
        expect(json['lastSyncTime'], null);
      });

      test('should deserialize from JSON with lastSyncTime', () {
        // arrange
        final lastSyncTime = DateTime(2024, 1, 1, 12, 0, 0);
        final json = {
          'entityTypes': ['TrainingPlan', 'Exercise'],
          'lastSyncTime': lastSyncTime.toIso8601String(),
        };

        // act
        final dto = SyncPullRequestDto.fromJson(json);

        // assert
        expect(dto.entityTypes, ['TrainingPlan', 'Exercise']);
        expect(dto.lastSyncTime, lastSyncTime);
      });

      test('should deserialize from JSON without lastSyncTime', () {
        // arrange
        final json = {
          'entityTypes': ['TrainingPlan'],
        };

        // act
        final dto = SyncPullRequestDto.fromJson(json);

        // assert
        expect(dto.entityTypes, ['TrainingPlan']);
        expect(dto.lastSyncTime, null);
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        // arrange
        final lastSyncTime = DateTime(2024, 1, 1, 12, 0, 0);
        final dto1 = SyncPullRequestDto(
          entityTypes: ['TrainingPlan'],
          lastSyncTime: lastSyncTime,
        );
        final dto2 = SyncPullRequestDto(
          entityTypes: ['TrainingPlan'],
          lastSyncTime: lastSyncTime,
        );

        // assert
        expect(dto1, dto2);
      });

      test('should not be equal when entityTypes differ', () {
        // arrange
        final dto1 = SyncPullRequestDto(
          entityTypes: ['TrainingPlan'],
          lastSyncTime: null,
        );
        final dto2 = SyncPullRequestDto(
          entityTypes: ['Exercise'],
          lastSyncTime: null,
        );

        // assert
        expect(dto1, isNot(dto2));
      });
    });
  });

  group('SyncPullResponseDto', () {
    group('Serialization', () {
      test('should serialize to JSON', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final dto = SyncPullResponseDto(
          entities: {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1'}
            ],
          },
          syncTimestamp: syncTimestamp,
          totalEntities: 1,
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['entities'], {
          'TrainingPlan': [
            {'id': '1', 'name': 'Plan 1'}
          ],
        });
        expect(json['syncTimestamp'], syncTimestamp.toIso8601String());
        expect(json['totalEntities'], 1);
      });

      test('should deserialize from JSON', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final json = {
          'entities': {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1'}
            ],
          },
          'syncTimestamp': syncTimestamp.toIso8601String(),
          'totalEntities': 1,
        };

        // act
        final dto = SyncPullResponseDto.fromJson(json);

        // assert
        expect(dto.entities, {
          'TrainingPlan': [
            {'id': '1', 'name': 'Plan 1'}
          ],
        });
        expect(dto.syncTimestamp, syncTimestamp);
        expect(dto.totalEntities, 1);
      });

      test('should handle empty entities map', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final json = {
          'entities': <String, List<Map<String, dynamic>>>{},
          'syncTimestamp': syncTimestamp.toIso8601String(),
          'totalEntities': 0,
        };

        // act
        final dto = SyncPullResponseDto.fromJson(json);

        // assert
        expect(dto.entities, isEmpty);
        expect(dto.totalEntities, 0);
      });

      test('should handle multiple entity types', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final json = {
          'entities': {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1'}
            ],
            'Exercise': [
              {'id': '2', 'name': 'Exercise 1'},
              {'id': '3', 'name': 'Exercise 2'}
            ],
          },
          'syncTimestamp': syncTimestamp.toIso8601String(),
          'totalEntities': 3,
        };

        // act
        final dto = SyncPullResponseDto.fromJson(json);

        // assert
        expect(dto.entities.length, 2);
        expect(dto.entities['TrainingPlan']?.length, 1);
        expect(dto.entities['Exercise']?.length, 2);
        expect(dto.totalEntities, 3);
      });
    });
  });

  group('SyncPushRequestDto', () {
    group('Serialization', () {
      test('should serialize to JSON', () {
        // arrange
        final dto = SyncPushRequestDto(
          entities: {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1', 'isDirty': true}
            ],
          },
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['entities'], {
          'TrainingPlan': [
            {'id': '1', 'name': 'Plan 1', 'isDirty': true}
          ],
        });
      });

      test('should deserialize from JSON', () {
        // arrange
        final json = {
          'entities': {
            'TrainingPlan': [
              {'id': '1', 'name': 'Plan 1', 'isDirty': true}
            ],
          },
        };

        // act
        final dto = SyncPushRequestDto.fromJson(json);

        // assert
        expect(dto.entities, {
          'TrainingPlan': [
            {'id': '1', 'name': 'Plan 1', 'isDirty': true}
          ],
        });
      });

      test('should handle empty entities map', () {
        // arrange
        final dto = SyncPushRequestDto(
          entities: {},
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['entities'], isEmpty);
      });
    });
  });

  group('SyncPushResponseDto', () {
    group('Serialization', () {
      test('should serialize to JSON with no failures', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final dto = SyncPushResponseDto(
          successCount: 5,
          failureCount: 0,
          failures: [],
          syncTimestamp: syncTimestamp,
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['successCount'], 5);
        expect(json['failureCount'], 0);
        expect(json['failures'], []);
        expect(json['syncTimestamp'], syncTimestamp.toIso8601String());
      });

      test('should deserialize from JSON with no failures', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final json = {
          'successCount': 5,
          'failureCount': 0,
          'failures': [],
          'syncTimestamp': syncTimestamp.toIso8601String(),
        };

        // act
        final dto = SyncPushResponseDto.fromJson(json);

        // assert
        expect(dto.successCount, 5);
        expect(dto.failureCount, 0);
        expect(dto.failures, isEmpty);
        expect(dto.syncTimestamp, syncTimestamp);
      });

      test('should serialize to JSON with failures', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final dto = SyncPushResponseDto(
          successCount: 3,
          failureCount: 2,
          failures: [
            EntityFailure(
              entityType: 'TrainingPlan',
              entityId: '1',
              errors: [
                ValidationError(
                  field: 'name',
                  code: 'required',
                  message: 'Name is required',
                ),
              ],
            ),
          ],
          syncTimestamp: syncTimestamp,
        );

        // act
        final json = dto.toJson();

        // assert
        expect(json['successCount'], 3);
        expect(json['failureCount'], 2);
        expect(json['failures'], isA<List>());
        expect(json['failures'].length, 1);
      });

      test('should deserialize from JSON with failures', () {
        // arrange
        final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
        final json = {
          'successCount': 3,
          'failureCount': 2,
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

        // act
        final dto = SyncPushResponseDto.fromJson(json);

        // assert
        expect(dto.successCount, 3);
        expect(dto.failureCount, 2);
        expect(dto.failures.length, 1);
        expect(dto.failures[0].entityType, 'TrainingPlan');
        expect(dto.failures[0].entityId, '1');
        expect(dto.failures[0].errors.length, 1);
      });
    });
  });

  group('EntityFailure', () {
    group('Serialization', () {
      test('should serialize to JSON', () {
        // arrange
        final failure = EntityFailure(
          entityType: 'TrainingPlan',
          entityId: '123',
          errors: [
            ValidationError(
              field: 'name',
              code: 'required',
              message: 'Name is required',
            ),
            ValidationError(
              field: 'duration',
              code: 'min',
              message: 'Duration must be at least 1',
            ),
          ],
        );

        // act
        final json = failure.toJson();

        // assert
        expect(json['entityType'], 'TrainingPlan');
        expect(json['entityId'], '123');
        expect(json['errors'], isA<List>());
        expect(json['errors'].length, 2);
      });

      test('should deserialize from JSON', () {
        // arrange
        final json = {
          'entityType': 'Exercise',
          'entityId': '456',
          'errors': [
            {
              'field': 'sets',
              'code': 'min',
              'message': 'Sets must be at least 1',
            },
          ],
        };

        // act
        final failure = EntityFailure.fromJson(json);

        // assert
        expect(failure.entityType, 'Exercise');
        expect(failure.entityId, '456');
        expect(failure.errors.length, 1);
        expect(failure.errors[0].field, 'sets');
        expect(failure.errors[0].code, 'min');
        expect(failure.errors[0].message, 'Sets must be at least 1');
      });

      test('should handle empty errors list', () {
        // arrange
        final failure = EntityFailure(
          entityType: 'User',
          entityId: '789',
          errors: [],
        );

        // act
        final json = failure.toJson();

        // assert
        expect(json['errors'], isEmpty);
      });
    });
  });

  group('ValidationError', () {
    group('Serialization', () {
      test('should serialize to JSON', () {
        // arrange
        final error = ValidationError(
          field: 'email',
          code: 'email',
          message: 'Invalid email format',
        );

        // act
        final json = error.toJson();

        // assert
        expect(json['field'], 'email');
        expect(json['code'], 'email');
        expect(json['message'], 'Invalid email format');
      });

      test('should deserialize from JSON', () {
        // arrange
        final json = {
          'field': 'password',
          'code': 'min_length',
          'message': 'Password must be at least 8 characters',
        };

        // act
        final error = ValidationError.fromJson(json);

        // assert
        expect(error.field, 'password');
        expect(error.code, 'min_length');
        expect(error.message, 'Password must be at least 8 characters');
      });
    });

    group('Equality', () {
      test('should be equal when all fields match', () {
        // arrange
        final error1 = ValidationError(
          field: 'name',
          code: 'required',
          message: 'Name is required',
        );
        final error2 = ValidationError(
          field: 'name',
          code: 'required',
          message: 'Name is required',
        );

        // assert
        expect(error1, error2);
      });

      test('should not be equal when fields differ', () {
        // arrange
        final error1 = ValidationError(
          field: 'name',
          code: 'required',
          message: 'Name is required',
        );
        final error2 = ValidationError(
          field: 'name',
          code: 'min_length',
          message: 'Name must be at least 3 characters',
        );

        // assert
        expect(error1, isNot(error2));
      });
    });
  });

  group('Round-trip serialization', () {
    test('SyncPullRequestDto should maintain data through round-trip', () {
      // arrange
      final lastSyncTime = DateTime(2024, 1, 1, 12, 0, 0);
      final original = SyncPullRequestDto(
        entityTypes: ['TrainingPlan', 'Exercise'],
        lastSyncTime: lastSyncTime,
      );

      // act
      final json = original.toJson();
      final deserialized = SyncPullRequestDto.fromJson(json);

      // assert
      expect(deserialized, original);
    });

    test('SyncPullResponseDto should maintain data through round-trip', () {
      // arrange
      final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final original = SyncPullResponseDto(
        entities: {
          'TrainingPlan': [
            {'id': '1', 'name': 'Plan 1'}
          ],
        },
        syncTimestamp: syncTimestamp,
        totalEntities: 1,
      );

      // act
      final json = original.toJson();
      final deserialized = SyncPullResponseDto.fromJson(json);

      // assert
      expect(deserialized, original);
    });

    test('SyncPushRequestDto should maintain data through round-trip', () {
      // arrange
      final original = SyncPushRequestDto(
        entities: {
          'Exercise': [
            {'id': '2', 'name': 'Exercise 1'}
          ],
        },
      );

      // act
      final json = original.toJson();
      final deserialized = SyncPushRequestDto.fromJson(json);

      // assert
      expect(deserialized, original);
    });

    test('SyncPushResponseDto should maintain data through round-trip', () {
      // arrange
      final syncTimestamp = DateTime(2024, 1, 1, 12, 0, 0);
      final original = SyncPushResponseDto(
        successCount: 3,
        failureCount: 1,
        failures: [
          EntityFailure(
            entityType: 'TrainingPlan',
            entityId: '1',
            errors: [
              ValidationError(
                field: 'name',
                code: 'required',
                message: 'Name is required',
              ),
            ],
          ),
        ],
        syncTimestamp: syncTimestamp,
      );

      // act
      final json = original.toJson();
      final deserialized = SyncPushResponseDto.fromJson(json);

      // assert
      expect(deserialized, original);
    });
  });
}
