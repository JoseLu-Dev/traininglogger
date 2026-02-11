/// Conflict resolution strategy
/// Currently uses client-wins, but can be extended for other strategies
class ConflictResolver {
  /// Resolve conflict between local and server entity
  /// Returns true if local should be kept, false if server should be used
  bool resolveConflict({
    required dynamic local,
    required dynamic server,
    required ConflictResolutionStrategy strategy,
  }) {
    switch (strategy) {
      case ConflictResolutionStrategy.clientWins:
        // If local is dirty, it wins
        return (local as dynamic).isDirty;

      case ConflictResolutionStrategy.serverWins:
        // Server always wins
        return false;

      case ConflictResolutionStrategy.latestTimestamp:
        // Compare updatedAt timestamps
        final localTime = (local as dynamic).updatedAt as DateTime;
        final serverTime = (server as dynamic).updatedAt as DateTime;
        return localTime.isAfter(serverTime);

      case ConflictResolutionStrategy.highestVersion:
        // Compare version numbers
        final localVersion = (local as dynamic).version as int;
        final serverVersion = (server as dynamic).version as int;
        return localVersion > serverVersion;
    }
  }
}

enum ConflictResolutionStrategy {
  clientWins,
  serverWins,
  latestTimestamp,
  highestVersion,
}
