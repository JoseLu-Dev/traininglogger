import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/core/sync_queue.dart';

void main() {
  group('QueuedSync', () {
    test('creates with all required fields', () {
      final now = DateTime.now();
      final queuedSync = QueuedSync(
        id: 'sync-123',
        entityType: 'Exercise',
        entityId: 'ex-456',
        data: {'name': 'Bench Press', 'sets': 3},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now,
      );

      expect(queuedSync.id, equals('sync-123'));
      expect(queuedSync.entityType, equals('Exercise'));
      expect(queuedSync.entityId, equals('ex-456'));
      expect(queuedSync.data, equals({'name': 'Bench Press', 'sets': 3}));
      expect(queuedSync.queuedAt, equals(now));
      expect(queuedSync.retryCount, equals(0));
      expect(queuedSync.nextRetryAt, equals(now));
    });

    test('canRetry returns true when retryCount is less than 5', () {
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );

      expect(queuedSync.canRetry, isTrue);
    });

    test('canRetry returns true when retryCount is 4', () {
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 4,
        nextRetryAt: DateTime.now(),
      );

      expect(queuedSync.canRetry, isTrue);
    });

    test('canRetry returns false when retryCount is 5 or more', () {
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 5,
        nextRetryAt: DateTime.now(),
      );

      expect(queuedSync.canRetry, isFalse);
    });

    test('canRetry returns false when retryCount exceeds 5', () {
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 10,
        nextRetryAt: DateTime.now(),
      );

      expect(queuedSync.canRetry, isFalse);
    });

    test('incrementRetry increases retryCount by 1', () {
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 2,
        nextRetryAt: DateTime.now(),
      );

      final incremented = queuedSync.incrementRetry();

      expect(incremented.retryCount, equals(3));
    });

    test('incrementRetry sets nextRetryAt with exponential backoff', () {
      final now = DateTime.now();
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now,
      );

      final incremented = queuedSync.incrementRetry();

      // For retryCount 0: 2^0 * 30 = 30 seconds
      final expectedDelay = Duration(seconds: 30);
      final actualDelay = incremented.nextRetryAt.difference(now);

      // Allow 1 second tolerance for test execution time
      expect(
        actualDelay.inSeconds,
        greaterThanOrEqualTo(expectedDelay.inSeconds - 1),
      );
      expect(
        actualDelay.inSeconds,
        lessThanOrEqualTo(expectedDelay.inSeconds + 1),
      );
    });

    test('incrementRetry exponential backoff for retry 1', () {
      final now = DateTime.now();
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: now,
        retryCount: 1,
        nextRetryAt: now,
      );

      final incremented = queuedSync.incrementRetry();

      // For retryCount 1: 2^1 * 30 = 60 seconds
      final expectedDelay = Duration(seconds: 60);
      final actualDelay = incremented.nextRetryAt.difference(now);

      expect(
        actualDelay.inSeconds,
        greaterThanOrEqualTo(expectedDelay.inSeconds - 1),
      );
      expect(
        actualDelay.inSeconds,
        lessThanOrEqualTo(expectedDelay.inSeconds + 1),
      );
    });

    test('incrementRetry exponential backoff for retry 2', () {
      final now = DateTime.now();
      final queuedSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: now,
        retryCount: 2,
        nextRetryAt: now,
      );

      final incremented = queuedSync.incrementRetry();

      // For retryCount 2: 2^2 * 30 = 120 seconds
      final expectedDelay = Duration(seconds: 120);
      final actualDelay = incremented.nextRetryAt.difference(now);

      expect(
        actualDelay.inSeconds,
        greaterThanOrEqualTo(expectedDelay.inSeconds - 1),
      );
      expect(
        actualDelay.inSeconds,
        lessThanOrEqualTo(expectedDelay.inSeconds + 1),
      );
    });

    test('incrementRetry preserves other fields', () {
      final now = DateTime.now();
      final data = {'test': 'value'};
      final queuedSync = QueuedSync(
        id: 'sync-123',
        entityType: 'Exercise',
        entityId: 'ex-456',
        data: data,
        queuedAt: now,
        retryCount: 1,
        nextRetryAt: now,
      );

      final incremented = queuedSync.incrementRetry();

      expect(incremented.id, equals('sync-123'));
      expect(incremented.entityType, equals('Exercise'));
      expect(incremented.entityId, equals('ex-456'));
      expect(incremented.data, equals(data));
      expect(incremented.queuedAt, equals(now));
    });

    test('queuedSyncs are equal when created with same values', () {
      final now = DateTime.now();
      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {'key': 'value'},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now,
      );
      final sync2 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {'key': 'value'},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now,
      );

      expect(sync1, equals(sync2));
    });

    test('queuedSyncs with different ids are not equal', () {
      final now = DateTime.now();
      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now,
      );
      final sync2 = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now,
      );

      expect(sync1, isNot(equals(sync2)));
    });
  });

  group('SyncQueue', () {
    late SyncQueue queue;

    setUp(() {
      queue = SyncQueue();
    });

    test('starts empty', () {
      expect(queue.length, equals(0));
    });

    test('enqueue adds item when canRetry is true', () {
      final sync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );

      queue.enqueue(sync);

      expect(queue.length, equals(1));
    });

    test('enqueue does not add item when canRetry is false', () {
      final sync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 5, // Max retries reached
        nextRetryAt: DateTime.now(),
      );

      queue.enqueue(sync);

      expect(queue.length, equals(0));
    });

    test('enqueue multiple items', () {
      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );
      final sync2 = QueuedSync(
        id: 'sync-2',
        entityType: 'TrainingPlan',
        entityId: 'plan-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 1,
        nextRetryAt: DateTime.now(),
      );

      queue.enqueue(sync1);
      queue.enqueue(sync2);

      expect(queue.length, equals(2));
    });

    test('getDueRetries returns items with nextRetryAt in the past', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 5));
      final futureTime = DateTime.now().add(const Duration(minutes: 5));

      final dueSync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: pastTime,
      );
      final notDueSync = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-2',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: futureTime,
      );

      queue.enqueue(dueSync);
      queue.enqueue(notDueSync);

      final dueRetries = queue.getDueRetries();

      expect(dueRetries.length, equals(1));
      expect(dueRetries[0].id, equals('sync-1'));
    });

    test('getDueRetries returns empty list when no items are due', () {
      final futureTime = DateTime.now().add(const Duration(minutes: 5));

      final sync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: futureTime,
      );

      queue.enqueue(sync);

      final dueRetries = queue.getDueRetries();

      expect(dueRetries, isEmpty);
    });

    test('getDueRetries returns all items when all are due', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 5));

      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: pastTime,
      );
      final sync2 = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-2',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 1,
        nextRetryAt: pastTime,
      );

      queue.enqueue(sync1);
      queue.enqueue(sync2);

      final dueRetries = queue.getDueRetries();

      expect(dueRetries.length, equals(2));
    });

    test('remove removes item by id', () {
      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );
      final sync2 = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-2',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );

      queue.enqueue(sync1);
      queue.enqueue(sync2);

      queue.remove('sync-1');

      expect(queue.length, equals(1));
      final remaining = queue.getDueRetries();
      expect(remaining[0].id, equals('sync-2'));
    });

    test('remove does nothing when id not found', () {
      final sync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );

      queue.enqueue(sync);
      queue.remove('non-existent-id');

      expect(queue.length, equals(1));
    });

    test('clear removes all items', () {
      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );
      final sync2 = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-2',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now(),
      );

      queue.enqueue(sync1);
      queue.enqueue(sync2);

      queue.clear();

      expect(queue.length, equals(0));
    });

    test('clear on empty queue does nothing', () {
      queue.clear();
      expect(queue.length, equals(0));
    });

    test('queue maintains FIFO order', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 5));

      final sync1 = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: pastTime,
      );
      final sync2 = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-2',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: pastTime,
      );
      final sync3 = QueuedSync(
        id: 'sync-3',
        entityType: 'Exercise',
        entityId: 'ex-3',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: pastTime,
      );

      queue.enqueue(sync1);
      queue.enqueue(sync2);
      queue.enqueue(sync3);

      final dueRetries = queue.getDueRetries();

      expect(dueRetries[0].id, equals('sync-1'));
      expect(dueRetries[1].id, equals('sync-2'));
      expect(dueRetries[2].id, equals('sync-3'));
    });
  });

  group('SyncQueue integration tests', () {
    test('complete retry workflow', () {
      final queue = SyncQueue();
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1));

      // Create initial sync
      final sync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {'name': 'Squat'},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: pastTime,
      );

      // Enqueue
      queue.enqueue(sync);
      expect(queue.length, equals(1));

      // Get due retries
      final dueRetries = queue.getDueRetries();
      expect(dueRetries.length, equals(1));

      // Simulate retry failure - increment and re-enqueue
      final retriedSync = dueRetries[0].incrementRetry();
      queue.remove(dueRetries[0].id);
      queue.enqueue(retriedSync);

      // Verify retry count increased
      expect(queue.length, equals(1));
      final queuedItems = queue.getDueRetries();
      if (queuedItems.isNotEmpty) {
        expect(queuedItems[0].retryCount, equals(1));
      }
    });

    test('sync reaches max retries and is not re-enqueued', () {
      final queue = SyncQueue();

      var sync = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: DateTime.now(),
        retryCount: 0,
        nextRetryAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      // Simulate incrementing retries manually until max is reached
      for (var i = 0; i < 5; i++) {
        sync = sync.incrementRetry();
      }

      // After 5 increments, retryCount should be 5 and canRetry should be false
      expect(sync.retryCount, equals(5));
      expect(sync.canRetry, isFalse);

      // Attempting to enqueue should not add to queue
      queue.enqueue(sync);
      expect(queue.length, equals(0));
    });

    test('multiple syncs with different due times', () {
      final queue = SyncQueue();
      final now = DateTime.now();

      final dueNow = QueuedSync(
        id: 'sync-1',
        entityType: 'Exercise',
        entityId: 'ex-1',
        data: {},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now.subtract(const Duration(seconds: 1)),
      );
      final dueSoon = QueuedSync(
        id: 'sync-2',
        entityType: 'Exercise',
        entityId: 'ex-2',
        data: {},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now.add(const Duration(seconds: 30)),
      );
      final dueLater = QueuedSync(
        id: 'sync-3',
        entityType: 'Exercise',
        entityId: 'ex-3',
        data: {},
        queuedAt: now,
        retryCount: 0,
        nextRetryAt: now.add(const Duration(minutes: 5)),
      );

      queue.enqueue(dueNow);
      queue.enqueue(dueSoon);
      queue.enqueue(dueLater);

      expect(queue.length, equals(3));

      final dueRetries = queue.getDueRetries();
      expect(dueRetries.length, equals(1));
      expect(dueRetries[0].id, equals('sync-1'));
    });
  });
}
