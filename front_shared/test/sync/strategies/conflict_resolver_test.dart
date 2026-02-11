import 'package:flutter_test/flutter_test.dart';
import 'package:front_shared/src/sync/strategies/conflict_resolver.dart';

void main() {
  late ConflictResolver resolver;

  setUp(() {
    resolver = ConflictResolver();
  });

  group('ConflictResolver - clientWins', () {
    test('returns true when local is dirty', () {
      final local = _MockEntity(isDirty: true);
      final server = _MockEntity(isDirty: false);

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.clientWins,
      );

      expect(result, true); // Local wins
    });

    test('returns false when local is not dirty', () {
      final local = _MockEntity(isDirty: false);
      final server = _MockEntity(isDirty: false);

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.clientWins,
      );

      expect(result, false); // Server wins
    });
  });

  group('ConflictResolver - serverWins', () {
    test('always returns false (server wins)', () {
      final local = _MockEntity(isDirty: true);
      final server = _MockEntity(isDirty: false);

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.serverWins,
      );

      expect(result, false); // Server always wins
    });

    test('returns false even when local is dirty', () {
      final local = _MockEntity(isDirty: true);
      final server = _MockEntity(isDirty: false);

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.serverWins,
      );

      expect(result, false); // Server wins
    });
  });

  group('ConflictResolver - latestTimestamp', () {
    test('returns true when local is newer', () {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));

      final local = _MockEntityWithTimestamp(
        isDirty: false,
        updatedAt: now,
      );
      final server = _MockEntityWithTimestamp(
        isDirty: false,
        updatedAt: earlier,
      );

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.latestTimestamp,
      );

      expect(result, true); // Local is newer, local wins
    });

    test('returns false when server is newer', () {
      final now = DateTime.now();
      final earlier = now.subtract(const Duration(hours: 1));

      final local = _MockEntityWithTimestamp(
        isDirty: false,
        updatedAt: earlier,
      );
      final server = _MockEntityWithTimestamp(
        isDirty: false,
        updatedAt: now,
      );

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.latestTimestamp,
      );

      expect(result, false); // Server is newer, server wins
    });

    test('returns false when timestamps are equal', () {
      final now = DateTime.now();

      final local = _MockEntityWithTimestamp(
        isDirty: false,
        updatedAt: now,
      );
      final server = _MockEntityWithTimestamp(
        isDirty: false,
        updatedAt: now,
      );

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.latestTimestamp,
      );

      expect(result, false); // Equal timestamps, server wins
    });
  });

  group('ConflictResolver - highestVersion', () {
    test('returns true when local version is higher', () {
      final local = _MockEntityWithVersion(
        isDirty: false,
        version: 5,
      );
      final server = _MockEntityWithVersion(
        isDirty: false,
        version: 3,
      );

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.highestVersion,
      );

      expect(result, true); // Local version is higher, local wins
    });

    test('returns false when server version is higher', () {
      final local = _MockEntityWithVersion(
        isDirty: false,
        version: 3,
      );
      final server = _MockEntityWithVersion(
        isDirty: false,
        version: 5,
      );

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.highestVersion,
      );

      expect(result, false); // Server version is higher, server wins
    });

    test('returns false when versions are equal', () {
      final local = _MockEntityWithVersion(
        isDirty: false,
        version: 3,
      );
      final server = _MockEntityWithVersion(
        isDirty: false,
        version: 3,
      );

      final result = resolver.resolveConflict(
        local: local,
        server: server,
        strategy: ConflictResolutionStrategy.highestVersion,
      );

      expect(result, false); // Equal versions, server wins
    });
  });
}

// Mock entities for testing
class _MockEntity {
  final bool isDirty;

  _MockEntity({required this.isDirty});
}

class _MockEntityWithTimestamp {
  final bool isDirty;
  final DateTime updatedAt;

  _MockEntityWithTimestamp({
    required this.isDirty,
    required this.updatedAt,
  });
}

class _MockEntityWithVersion {
  final bool isDirty;
  final int version;

  _MockEntityWithVersion({
    required this.isDirty,
    required this.version,
  });
}
