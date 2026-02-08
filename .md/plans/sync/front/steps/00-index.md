# LiftLogger Frontend Sync - Step-by-Step Implementation Plan

## Overview
This directory contains a detailed, step-by-step plan for implementing offline-first sync in the LiftLogger Flutter apps.

## Implementation Steps

### Phase 1: Foundation (Steps 1-6) - ~8 hours
- **[01-project-setup.md](01-project-setup.md)** (30 min)
  - Create package structure
  - Install dependencies
  - Setup library exports

- **[02-base-infrastructure.md](02-base-infrastructure.md)** (1 hour)
  - Create SyncableEntity interface
  - Create SyncableTable mixin
  - Create BaseDao abstract class
  - Create sync state models

- **[03-network-layer.md](03-network-layer.md)** (1.5 hours)
  - Implement NetworkInfo
  - Create SecureStorageService
  - Build ApiClient with token refresh

- **[04-sync-dtos.md](04-sync-dtos.md)** (1.5 hours)
  - Create sync DTOs (pull/push)
  - Implement SyncApiService
  - Error handling

- **[05-entity-registry.md](05-entity-registry.md)** (1.5 hours)
  - Create generic EntityRegistry
  - Registry setup function
  - Unit tests

- **[06-database-setup.md](06-database-setup.md)** (45 min)
  - Setup AppDatabase
  - Database providers
  - Test helpers

### Phase 2: Core Sync (Steps 7-10) - ~10 hours
- **[07-first-entity-training-plan.md](07-first-entity-training-plan.md)** (2-3 hours)
  - Complete TrainingPlan implementation
  - Pattern for other entities
  - Registry registration

- **[08-sync-strategies.md](08-sync-strategies.md)** (2-3 hours)
  - Implement PullStrategy
  - Implement PushStrategy
  - Create ConflictResolver

- **[09-sync-manager.md](09-sync-manager.md)** (2 hours)
  - Orchestrate PULL → PUSH → RETRY
  - Auto-sync service
  - State management

- **[10-authentication.md](10-authentication.md)** (2 hours)
  - Offline-first auth
  - Password hash caching
  - Auth state management

### Phase 3: Testing & Extension (Steps 11-12) - ~18 hours
- **[11-integration-testing.md](11-integration-testing.md)** (2-3 hours)
  - End-to-end sync tests
  - Performance tests
  - Integration test helpers

- **[12-remaining-entities.md](12-remaining-entities.md)** (11-22 hours)
  - Implement 10 remaining entities
  - Follow TrainingPlan pattern
  - Each entity: 1-2 hours (User entity slightly longer due to role handling)

### Phase 4: Finalization (Step 13) - ~6 hours
- **[13-final-integration.md](13-final-integration.md)** (4-6 hours)
  - Export public APIs
  - Create UI components
  - Write documentation
  - Example app
  - Final testing

## Total Estimated Time
**42-57 hours** (~1-1.5 weeks for one developer)

## Key Deliverables

### Code
- ✅ Complete offline-first sync system
- ✅ 12 entity types with full CRUD
- ✅ Generic registry pattern (extensible)
- ✅ Automatic background sync
- ✅ Offline authentication
- ✅ Comprehensive test suite

### Documentation
- ✅ Integration guide
- ✅ API documentation
- ✅ README with architecture
- ✅ Example usage
- ✅ Testing checklist

### Performance Targets
- ✅ 100 entities created in <5s
- ✅ Find all dirty in <1s
- ✅ Query by athlete in <100ms
- ✅ API sync <2s for 100 entities

## Usage

1. Follow steps in order (01 → 13)
2. Run code generation after each step that adds models/tables
3. Run tests frequently to catch issues early
4. Use the checklist in step 12 to track entity implementation progress

## Quick Reference

### Running Code Generation
```bash
cd front_shared
dart run build_runner watch --delete-conflicting-outputs
```

### Running Tests
```bash
cd front_shared
flutter test
```

### Adding a New Entity
See step 12 for the complete pattern and checklist.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (UI)                     │
│                                                         │
│  [ConsumerWidget] → [Repository] → [DAO] → [Drift DB]  │
│         ↓                                               │
│    [SyncManager]                                        │
│         ↓                                               │
│    PULL → PUSH → RETRY                                  │
│         ↓                                               │
│   [SyncApiService] ←→ Backend API                       │
└─────────────────────────────────────────────────────────┘
```

## Key Design Decisions

1. **Client-Wins Conflict Resolution**: Local changes always win over server
2. **Optimistic Updates**: UI updates immediately, sync happens in background
3. **Generic Registry**: No switch statements, easy to add entities
4. **Exponential Backoff**: 30s → 60s → 2m → 4m → 8m, max 5 retries
5. **Offline-First Auth**: SHA-256 password hash cached for offline login

## Next Steps After Completion

1. Integrate into `front_athlete` app
2. Integrate into `front_coach` app
3. Add monitoring/analytics
4. Performance optimization for large datasets
5. Consider adding server-side webhooks for real-time updates

## Support

For questions or issues during implementation:
- Review the implementation plan (`implementation-plan.md`)
- Check backend sync API plan (`.md/plans/sync/back/pull-push-api.md`)
- Review datamodel (`.md/plans/datamodel.md`)
