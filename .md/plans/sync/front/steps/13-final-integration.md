# Step 13: Final Integration & Documentation

## Goal
Integrate the sync system into the athlete and coach apps, add UI indicators, and create comprehensive documentation.

## Tasks

### 1. Export all public APIs
Update `lib/front_shared.dart`:
```dart
library front_shared;

// Domain Models
export 'src/domain/models/syncable_entity.dart';
export 'src/domain/models/training_plan.dart';
export 'src/domain/models/athlete.dart';
export 'src/domain/models/coach.dart';
export 'src/domain/models/exercise.dart';
export 'src/domain/models/variant.dart';
export 'src/domain/models/exercise_plan.dart';
export 'src/domain/models/set_plan.dart';
export 'src/domain/models/training_session.dart';
export 'src/domain/models/exercise_session.dart';
export 'src/domain/models/set_session.dart';
export 'src/domain/models/body_weight_entry.dart';

// Repositories
export 'src/domain/repositories/training_plan_repository.dart';
export 'src/domain/repositories/athlete_repository.dart';
// ... export other repositories

// Sync
export 'src/sync/core/sync_manager.dart';
export 'src/sync/core/sync_state.dart';
export 'src/sync/core/sync_queue.dart';

// Auth
export 'src/auth/auth_service.dart';
export 'src/auth/auth_state.dart';

// Providers
export 'src/providers/database_providers.dart';
export 'src/providers/network_providers.dart';
export 'src/providers/sync_providers.dart';
export 'src/providers/repository_providers.dart';
export 'src/providers/auth_providers.dart';

// Core
export 'src/core/api_constants.dart';
```

### 2. Create sync UI widgets (for apps to use)
Create `lib/src/ui/sync_indicator.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sync_providers.dart';
import '../sync/core/sync_state.dart';

/// Widget that shows sync status
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) {
        return state.when(
          idle: () => const SizedBox.shrink(),
          syncing: (phase) => _buildSyncingIndicator(phase),
          completed: (result) => _buildCompletedIndicator(result),
          error: (message) => _buildErrorIndicator(message),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => _buildErrorIndicator(error.toString()),
    );
  }

  Widget _buildSyncingIndicator(String phase) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            phase,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedIndicator(SyncResult result) {
    return result.when(
      success: (pullCount, pushCount, _) {
        if (pullCount == 0 && pushCount == 0) {
          return const SizedBox.shrink();
        }
        return _buildMessage(
          'Synced: ↓$pullCount ↑$pushCount',
          Colors.green.shade100,
          Icons.check_circle,
        );
      },
      partialSuccess: (pullCount, pushSuccess, pushFail, _, __) {
        return _buildMessage(
          'Partial sync: ↑$pushSuccess succeeded, $pushFail failed',
          Colors.orange.shade100,
          Icons.warning,
        );
      },
      failure: (message, _, __) {
        return _buildMessage(
          'Sync failed',
          Colors.red.shade100,
          Icons.error,
        );
      },
    );
  }

  Widget _buildErrorIndicator(String message) {
    return _buildMessage(
      'Sync error',
      Colors.red.shade100,
      Icons.error,
    );
  }

  Widget _buildMessage(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Button to manually trigger sync
class SyncButton extends ConsumerWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncManager = ref.watch(syncManagerProvider);

    return IconButton(
      icon: const Icon(Icons.sync),
      onPressed: () async {
        await syncManager.sync();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sync completed')),
          );
        }
      },
    );
  }
}

/// Offline indicator
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkInfo = ref.watch(networkInfoProvider);

    return FutureBuilder<bool>(
      future: networkInfo.isConnected,
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 14),
                SizedBox(width: 6),
                Text(
                  'Offline',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

Export UI widgets:
```dart
// Add to lib/front_shared.dart
export 'src/ui/sync_indicator.dart';
```

### 3. Create integration guide
Create `lib/docs/INTEGRATION_GUIDE.md`:
```markdown
# LiftLogger Offline-First Sync - Integration Guide

## Overview
This guide shows how to integrate the offline-first sync system into your Flutter app.

## Setup

### 1. Add front_shared dependency
```yaml
dependencies:
  front_shared:
    path: ../front_shared
```

### 2. Initialize providers in main.dart
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 3. Start auto-sync service
```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auto-sync service
    ref.watch(autoSyncServiceProvider);

    return MaterialApp(
      home: const HomePage(),
    );
  }
}
```

## Authentication

### Login
```dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.watch(authNotifierProvider.notifier);
    final authState = ref.watch(authNotifierProvider);

    return authState.when(
      initial: () => _buildLoginForm(authNotifier),
      loading: () => const CircularProgressIndicator(),
      authenticated: (id, email, role, coachId, isOffline) {
        // Navigate to home
        return HomePage();
      },
      unauthenticated: () => _buildLoginForm(authNotifier),
      error: (message) => Text('Error: $message'),
    );
  }

  Widget _buildLoginForm(AuthNotifier notifier) {
    return ElevatedButton(
      onPressed: () {
        notifier.login(emailController.text, passwordController.text);
      },
      child: const Text('Login'),
    );
  }
}
```

## Using Repositories

### Read Data
```dart
class TrainingPlansPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(trainingPlanRepositoryProvider);

    return FutureBuilder<List<TrainingPlan>>(
      future: repository.findByAthleteId('athlete-1'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final plan = snapshot.data![index];
              return ListTile(
                title: Text(plan.name),
                subtitle: Text(plan.date.toString()),
                trailing: plan.isDirty
                    ? const Icon(Icons.sync, color: Colors.orange)
                    : null,
              );
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```

### Create Data
```dart
Future<void> createTrainingPlan(WidgetRef ref) async {
  final repository = ref.read(trainingPlanRepositoryProvider);

  final plan = TrainingPlan.create(
    athleteId: 'athlete-1',
    name: 'Monday Workout',
    date: DateTime.now(),
  );

  await repository.create(plan);

  // Will automatically sync when online
}
```

### Update Data
```dart
Future<void> updateTrainingPlan(WidgetRef ref, String planId) async {
  final repository = ref.read(trainingPlanRepositoryProvider);

  // Just mark as dirty - sync will handle the rest
  await repository.update(
    plan.copyWith(name: 'Updated Name'),
  );
}
```

## Manual Sync

### Trigger sync manually
```dart
Future<void> manualSync(WidgetRef ref) async {
  final syncManager = ref.read(syncManagerProvider);

  final result = await syncManager.sync();

  result.when(
    success: (pullCount, pushCount, _) {
      print('Sync successful: ↓$pullCount ↑$pushCount');
    },
    partialSuccess: (_, __, ___, failures, ____) {
      print('Partial sync: ${failures.length} failures');
    },
    failure: (message, _, __) {
      print('Sync failed: $message');
    },
  );
}
```

## UI Components

### Add sync indicator to AppBar
```dart
AppBar(
  title: const Text('LiftLogger'),
  actions: [
    const OfflineIndicator(),
    const SyncButton(),
    const SyncIndicator(),
  ],
)
```

## Monitoring Sync State

### Listen to sync events
```dart
class SyncMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncStateProvider);

    return syncState.when(
      data: (state) {
        return state.when(
          idle: () => const Text('Idle'),
          syncing: (phase) => Text('Syncing: $phase'),
          completed: (result) => Text('Completed'),
          error: (message) => Text('Error: $message'),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => Text('Error: $error'),
    );
  }
}
```

## Best Practices

1. **Always use repositories** - Never access DAOs directly from UI
2. **Trust the sync** - Don't manually check network before operations
3. **Show dirty indicators** - Let users know what hasn't synced yet
4. **Handle partial failures** - Some entities may fail while others succeed
5. **Test offline** - Airplane mode is your friend

## Troubleshooting

### Sync not working
- Check network connectivity
- Verify authentication token is valid
- Check server logs for errors

### Data not appearing
- Ensure entity is registered in EntityRegistry
- Check if entity is marked as deleted
- Verify foreign key relationships

### Performance issues
- Check database indexes are created
- Use pagination for large datasets
- Profile with Flutter DevTools
```

### 4. Create README for front_shared
Create `lib/README.md`:
```markdown
# front_shared - LiftLogger Offline-First Sync Package

Shared Flutter package providing offline-first data synchronization for LiftLogger athlete and coach apps.

## Features

- ✅ **Offline-First**: All data stored locally in Drift SQLite database
- ✅ **Automatic Sync**: PULL → PUSH → RETRY flow with exponential backoff
- ✅ **Client-Wins Conflict Resolution**: Local changes always win
- ✅ **Optimistic Updates**: UI updates immediately, syncs in background
- ✅ **Type-Safe**: Freezed models, Drift tables, compile-time safety
- ✅ **Extensible**: Generic registry pattern for easy entity addition
- ✅ **Offline Authentication**: Cached password hash for offline login

## Architecture

```
User Action → Local DB (isDirty=true) → UI Updates → Background Sync
                                                          ↓
                                        PULL (server → local) → PUSH (local → server) → RETRY (failures)
```

## Quick Start

See [INTEGRATION_GUIDE.md](docs/INTEGRATION_GUIDE.md) for detailed setup instructions.

## Project Structure

```
lib/src/
├── domain/          # Business models and repository interfaces
├── data/            # Data layer (DAOs, API clients, repositories)
├── sync/            # Sync logic (strategies, manager, registry)
├── auth/            # Authentication service
├── providers/       # Riverpod providers
├── ui/              # Reusable UI components
└── core/            # Core utilities (network info, constants)
```

## Key Components

- **EntityRegistry**: Generic registry for entity types, DAOs, and serializers
- **SyncManager**: Orchestrates PULL → PUSH → RETRY flow
- **PullStrategy**: Merges server changes into local DB
- **PushStrategy**: Sends local changes to server with retry queue
- **BaseDao**: Abstract DAO with sync methods
- **SyncableTable**: Mixin adding sync fields to Drift tables

## Adding a New Entity

1. Create domain model implementing `SyncableEntity`
2. Create table extending `SyncableTable`
3. Create DAO extending `BaseDao`
4. Create repository interface and implementation
5. Register in `EntityRegistry`
6. Run code generation

Time: ~1-2 hours per entity

## Testing

```bash
flutter test
```

## Code Generation

```bash
dart run build_runner watch --delete-conflicting-outputs
```
```

### 5. Create example usage
Create `example/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:front_shared/front_shared.dart';

void main() {
  runApp(const ProviderScope(child: ExampleApp()));
}

class ExampleApp extends ConsumerWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize auto-sync
    ref.watch(autoSyncServiceProvider);

    return MaterialApp(
      title: 'Sync Example',
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends ConsumerWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(trainingPlanRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Example'),
        actions: const [
          OfflineIndicator(),
          SyncButton(),
          SyncIndicator(),
        ],
      ),
      body: FutureBuilder(
        future: repository.findAllActive(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final plans = snapshot.data as List<TrainingPlan>;
            return ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return ListTile(
                  title: Text(plan.name),
                  subtitle: Text(plan.date.toString()),
                  trailing: plan.isDirty
                      ? const Icon(Icons.sync, color: Colors.orange)
                      : const Icon(Icons.check, color: Colors.green),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final plan = TrainingPlan.create(
            athleteId: 'athlete-1',
            name: 'New Plan',
            date: DateTime.now(),
          );
          await repository.create(plan);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### 6. Final testing checklist
Create `TESTING_CHECKLIST.md`:
```markdown
# Testing Checklist

## Unit Tests
- [ ] All DAO tests pass
- [ ] All repository tests pass
- [ ] Sync strategy tests pass
- [ ] Auth service tests pass
- [ ] Entity registry tests pass

## Integration Tests
- [ ] End-to-end sync flow works
- [ ] Conflict resolution works
- [ ] Partial sync failures queue correctly
- [ ] Retry queue processes successfully

## Performance Tests
- [ ] 100 entities created in <5s
- [ ] Find all dirty in <1s
- [ ] Query by athlete in <100ms

## Manual Tests
- [ ] Offline create → online sync works
- [ ] Offline edit → online sync works
- [ ] Offline delete → online sync works
- [ ] Conflict resolution (client wins)
- [ ] Partial sync failures
- [ ] Retry queue exponential backoff
- [ ] Offline login with cached hash
- [ ] Online login and cache
- [ ] Auto-sync on connectivity restore
- [ ] Manual sync button works
- [ ] Sync indicators display correctly
- [ ] Offline indicator shows when offline

## Edge Cases
- [ ] Sync during sync (should fail gracefully)
- [ ] Network drops during sync
- [ ] Server returns 500 error
- [ ] Server returns validation errors
- [ ] Token expires during sync
- [ ] Max retries reached
- [ ] Empty database sync
- [ ] Large dataset (1000+ entities)
```

## Success Criteria
- ✅ All public APIs exported
- ✅ UI components created and documented
- ✅ Integration guide written
- ✅ README comprehensive
- ✅ Example app works
- ✅ All tests pass
- ✅ Manual testing complete

## Estimated Time
4-6 hours

## Final Step
Ready for integration into front_athlete and front_coach apps!
