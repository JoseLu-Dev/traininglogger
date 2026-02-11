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

## Supported Entities

The package currently supports 12 entity types:

1. **User** - Athletes and coaches
2. **TrainingPlan** - Weekly training plans
3. **TrainingSession** - Individual workout sessions
4. **Exercise** - Exercise definitions
5. **Variant** - Exercise variations
6. **ExercisePlan** - Exercises in a training plan
7. **ExercisePlanVariant** - Variants for planned exercises
8. **ExerciseSession** - Exercises performed in a session
9. **ExerciseSessionVariant** - Variants for session exercises
10. **SetPlan** - Planned sets
11. **SetSession** - Performed sets
12. **BodyWeightEntry** - Body weight tracking

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

Current test coverage: 342+ tests passing

## Code Generation

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Performance

Benchmarked with realistic datasets:
- 100 entities created: < 5s
- Find all dirty: < 1s
- Query by athlete: < 100ms

## Dependencies

- **drift**: SQLite database and type-safe queries
- **freezed**: Immutable models with code generation
- **riverpod**: State management and dependency injection
- **dio**: HTTP client for API communication
- **connectivity_plus**: Network connectivity detection
- **flutter_secure_storage**: Secure storage for tokens

## License

Proprietary - LiftLogger Project
