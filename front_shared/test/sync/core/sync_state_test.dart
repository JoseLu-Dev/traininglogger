import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/sync_state.dart';

void main() {
  group('SyncState', () {
    test('idle state is created correctly', () {
      const state = SyncState.idle();

      expect(state, isA<SyncState>());
      state.when(
        idle: () => true,
        syncing: (_) => false,
        completed: (_) => false,
        error: (_) => false,
      );
    });

    test('syncing state stores phase', () {
      const phase = 'Uploading data';
      const state = SyncState.syncing(phase: phase);

      expect(state, isA<SyncState>());
      state.when(
        idle: () => fail('Should be syncing'),
        syncing: (p) {
          expect(p, equals(phase));
          return true;
        },
        completed: (_) => fail('Should be syncing'),
        error: (_) => fail('Should be syncing'),
      );
    });

    test('completed state stores result', () {
      final result = SyncResult.success(
        pullCount: 5,
        pushCount: 3,
        timestamp: DateTime.now(),
      );
      final state = SyncState.completed(result);

      expect(state, isA<SyncState>());
      state.when(
        idle: () => fail('Should be completed'),
        syncing: (_) => fail('Should be completed'),
        completed: (r) {
          expect(r, equals(result));
          return true;
        },
        error: (_) => fail('Should be completed'),
      );
    });

    test('error state stores message', () {
      const errorMsg = 'Network connection failed';
      const state = SyncState.error(errorMsg);

      expect(state, isA<SyncState>());
      state.when(
        idle: () => fail('Should be error'),
        syncing: (_) => fail('Should be error'),
        completed: (_) => fail('Should be error'),
        error: (msg) {
          expect(msg, equals(errorMsg));
          return true;
        },
      );
    });

    test('states are equal when created with same values', () {
      const state1 = SyncState.idle();
      const state2 = SyncState.idle();

      expect(state1, equals(state2));
    });

    test('syncing states with same phase are equal', () {
      const state1 = SyncState.syncing(phase: 'test');
      const state2 = SyncState.syncing(phase: 'test');

      expect(state1, equals(state2));
    });

    test('syncing states with different phases are not equal', () {
      const state1 = SyncState.syncing(phase: 'phase1');
      const state2 = SyncState.syncing(phase: 'phase2');

      expect(state1, isNot(equals(state2)));
    });
  });

  group('SyncResult', () {
    test('success result stores counts and timestamp', () {
      final timestamp = DateTime.now();
      final result = SyncResult.success(
        pullCount: 10,
        pushCount: 5,
        timestamp: timestamp,
      );

      expect(result, isA<SyncResult>());
      result.when(
        success: (pull, push, ts) {
          expect(pull, equals(10));
          expect(push, equals(5));
          expect(ts, equals(timestamp));
          return true;
        },
        partialSuccess: (_, __, ___, ____, _____) => fail('Should be success'),
        failure: (_, __, ___) => fail('Should be success'),
      );
    });

    test('partialSuccess result stores all data including failures', () {
      final timestamp = DateTime.now();
      final failures = [
        const EntityFailure(
          entityType: 'Exercise',
          entityId: '123',
          errors: [
            ValidationError(
              field: 'name',
              code: 'required',
              message: 'Name is required',
            ),
          ],
        ),
      ];

      final result = SyncResult.partialSuccess(
        pullCount: 8,
        pushSuccessCount: 3,
        pushFailureCount: 2,
        failures: failures,
        timestamp: timestamp,
      );

      expect(result, isA<SyncResult>());
      result.when(
        success: (_, __, ___) => fail('Should be partialSuccess'),
        partialSuccess: (pull, pushSuccess, pushFailure, fails, ts) {
          expect(pull, equals(8));
          expect(pushSuccess, equals(3));
          expect(pushFailure, equals(2));
          expect(fails, equals(failures));
          expect(ts, equals(timestamp));
          return true;
        },
        failure: (_, __, ___) => fail('Should be partialSuccess'),
      );
    });

    test('failure result stores error details', () {
      final timestamp = DateTime.now();
      const errorMsg = 'Server unreachable';
      final error = Exception('Connection timeout');

      final result = SyncResult.failure(
        message: errorMsg,
        error: error,
        timestamp: timestamp,
      );

      expect(result, isA<SyncResult>());
      result.when(
        success: (_, __, ___) => fail('Should be failure'),
        partialSuccess: (_, __, ___, ____, _____) => fail('Should be failure'),
        failure: (msg, err, ts) {
          expect(msg, equals(errorMsg));
          expect(err, equals(error));
          expect(ts, equals(timestamp));
          return true;
        },
      );
    });

    test('failure result can have null error', () {
      final timestamp = DateTime.now();
      final result = SyncResult.failure(
        message: 'Unknown error',
        error: null,
        timestamp: timestamp,
      );

      result.when(
        success: (_, __, ___) => fail('Should be failure'),
        partialSuccess: (_, __, ___, ____, _____) => fail('Should be failure'),
        failure: (msg, err, ts) {
          expect(err, isNull);
          return true;
        },
      );
    });

    test('results are equal when created with same values', () {
      final timestamp = DateTime(2024, 1, 1);
      final result1 = SyncResult.success(
        pullCount: 5,
        pushCount: 3,
        timestamp: timestamp,
      );
      final result2 = SyncResult.success(
        pullCount: 5,
        pushCount: 3,
        timestamp: timestamp,
      );

      expect(result1, equals(result2));
    });

    test('results with different counts are not equal', () {
      final timestamp = DateTime.now();
      final result1 = SyncResult.success(
        pullCount: 5,
        pushCount: 3,
        timestamp: timestamp,
      );
      final result2 = SyncResult.success(
        pullCount: 10,
        pushCount: 3,
        timestamp: timestamp,
      );

      expect(result1, isNot(equals(result2)));
    });
  });

  group('EntityFailure', () {
    test('stores entity information and errors', () {
      const failure = EntityFailure(
        entityType: 'TrainingPlan',
        entityId: 'plan-123',
        errors: [
          ValidationError(
            field: 'name',
            code: 'required',
            message: 'Name is required',
          ),
          ValidationError(
            field: 'duration',
            code: 'min_value',
            message: 'Duration must be at least 1',
          ),
        ],
      );

      expect(failure.entityType, equals('TrainingPlan'));
      expect(failure.entityId, equals('plan-123'));
      expect(failure.errors.length, equals(2));
      expect(failure.errors[0].field, equals('name'));
      expect(failure.errors[1].field, equals('duration'));
    });

    test('can have empty errors list', () {
      const failure = EntityFailure(
        entityType: 'Exercise',
        entityId: '456',
        errors: [],
      );

      expect(failure.errors, isEmpty);
    });

    test('failures are equal when created with same values', () {
      const errors = [
        ValidationError(
          field: 'test',
          code: 'invalid',
          message: 'Invalid value',
        ),
      ];

      const failure1 = EntityFailure(
        entityType: 'Type',
        entityId: '123',
        errors: errors,
      );
      const failure2 = EntityFailure(
        entityType: 'Type',
        entityId: '123',
        errors: errors,
      );

      expect(failure1, equals(failure2));
    });

    test('failures with different entity types are not equal', () {
      const failure1 = EntityFailure(
        entityType: 'TypeA',
        entityId: '123',
        errors: [],
      );
      const failure2 = EntityFailure(
        entityType: 'TypeB',
        entityId: '123',
        errors: [],
      );

      expect(failure1, isNot(equals(failure2)));
    });
  });

  group('ValidationError', () {
    test('stores validation error details', () {
      const error = ValidationError(
        field: 'email',
        code: 'format',
        message: 'Invalid email format',
      );

      expect(error.field, equals('email'));
      expect(error.code, equals('format'));
      expect(error.message, equals('Invalid email format'));
    });

    test('errors are equal when created with same values', () {
      const error1 = ValidationError(
        field: 'test',
        code: 'code',
        message: 'message',
      );
      const error2 = ValidationError(
        field: 'test',
        code: 'code',
        message: 'message',
      );

      expect(error1, equals(error2));
    });

    test('errors with different fields are not equal', () {
      const error1 = ValidationError(
        field: 'field1',
        code: 'code',
        message: 'message',
      );
      const error2 = ValidationError(
        field: 'field2',
        code: 'code',
        message: 'message',
      );

      expect(error1, isNot(equals(error2)));
    });

    test('errors with different codes are not equal', () {
      const error1 = ValidationError(
        field: 'field',
        code: 'code1',
        message: 'message',
      );
      const error2 = ValidationError(
        field: 'field',
        code: 'code2',
        message: 'message',
      );

      expect(error1, isNot(equals(error2)));
    });
  });

  group('SyncResult integration', () {
    test('partialSuccess with multiple entity failures', () {
      final failures = [
        const EntityFailure(
          entityType: 'Exercise',
          entityId: 'ex-1',
          errors: [
            ValidationError(
              field: 'name',
              code: 'required',
              message: 'Name is required',
            ),
          ],
        ),
        const EntityFailure(
          entityType: 'TrainingPlan',
          entityId: 'plan-2',
          errors: [
            ValidationError(
              field: 'startDate',
              code: 'invalid_date',
              message: 'Invalid start date',
            ),
            ValidationError(
              field: 'endDate',
              code: 'invalid_date',
              message: 'End date must be after start date',
            ),
          ],
        ),
      ];

      final result = SyncResult.partialSuccess(
        pullCount: 15,
        pushSuccessCount: 8,
        pushFailureCount: 2,
        failures: failures,
        timestamp: DateTime.now(),
      );

      result.when(
        success: (_, __, ___) => fail('Should be partialSuccess'),
        partialSuccess: (pull, pushSuccess, pushFailure, fails, ts) {
          expect(fails.length, equals(2));
          expect(fails[0].errors.length, equals(1));
          expect(fails[1].errors.length, equals(2));
          expect(pushSuccess + pushFailure, equals(10));
          return true;
        },
        failure: (_, __, ___) => fail('Should be partialSuccess'),
      );
    });

    test('success result with zero counts', () {
      final result = SyncResult.success(
        pullCount: 0,
        pushCount: 0,
        timestamp: DateTime.now(),
      );

      result.when(
        success: (pull, push, ts) {
          expect(pull, equals(0));
          expect(push, equals(0));
          return true;
        },
        partialSuccess: (_, __, ___, ____, _____) => fail('Should be success'),
        failure: (_, __, ___) => fail('Should be success'),
      );
    });

    test('different result types are not equal', () {
      final timestamp = DateTime.now();
      final success = SyncResult.success(
        pullCount: 5,
        pushCount: 3,
        timestamp: timestamp,
      );
      final failure = SyncResult.failure(
        message: 'Error',
        error: null,
        timestamp: timestamp,
      );

      expect(success, isNot(equals(failure)));
    });
  });
}
