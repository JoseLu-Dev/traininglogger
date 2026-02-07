# 🚀 LiftLogger Offline-First Architecture Guide

## 📋 Key Decisions

**Conflict Resolution:** Client wins (local changes always preserved)
**Sync Strategy:** Entity-level, optimistic updates
**ID Generation:** Client-generated UUIDs
**Sync Triggers:** App launch + after edits
**Tech Stack:** Spring Boot + PostgreSQL | Flutter + Drift + Riverpod

---

## 🏗️ Tech Stack

**Backend:** Spring Boot 4.0.2 + PostgreSQL + Spring Data JPA + Spring Security
**Frontend:** Flutter + Drift 2.x (SQLite) + Riverpod 2.x + Dio + connectivity_plus + uuid
**Shared Package:** Domain models, Drift schema, repositories, sync engine, API client

---

## 🗄️ Database Schema

### Required Sync Metadata (Add to ALL entities)

**Backend (PostgreSQL):**

```sql
-- Add to every table
id              UUID PRIMARY KEY,
created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
updated_at      TIMESTAMP NOT NULL DEFAULT NOW(),
version         INTEGER NOT NULL DEFAULT 1,
deleted_at      TIMESTAMP              -- Soft delete (NULL = active)
```

**Frontend (Drift/SQLite):**

```dart
// Add to every table
abstract class SyncableTable extends Table {
  TextColumn get id => text().clientDefault(() => Uuid().v4())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Client-side sync tracking
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Critical Indexes

```sql
-- Backend (PostgreSQL)
CREATE INDEX idx_athlete_coach ON athlete(coach_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_training_plan_athlete ON training_plan(athlete_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_updated_at ON training_plan(updated_at);
```

---

## 🔄 Sync Algorithm

### Flow

1. **Pull:** Fetch server changes since `lastSyncTimestamp`
2. **Push:** Send local `isDirty` records to server
3. **Conflicts:** Client wins (overwrite server version)
4. **Failed syncs:** Queue with exponential backoff retry

### Conflict Resolution: Client Wins

```
IF local.isDirty AND server.version > local.version THEN
    server.save(clientData)  // Client overwrites server
    server.version++
END IF
```

### Retry Queue (Exponential Backoff)

```dart
// Failed syncs: retry at 30s, 60s, 120s, 240s...
final nextRetry = now.add(Duration(seconds: pow(2, retryCount) * 30));
```

---

## 🔐 Authentication

### Offline Login

**First Login (online):** Cache session token + password hash in `flutter_secure_storage`
**Subsequent (offline):** Validate against cached password hash

```dart
Future<bool> login(String username, String password) async {
  if (await isOnline()) {
    final response = await api.login(username, password);
    await secureStorage.save(response.token, hashPassword(password));
    return true;
  } else {
    return hashPassword(password) == await secureStorage.getPasswordHash(username);
  }
}
```

### Data Isolation

**Athlete App:** `WHERE athlete_id = currentUserId`
**Coach App:** `WHERE coach_id = currentUserId` (returns all their athletes)
**Backend:** Enforce with `@PreAuthorize` + validate ownership in controllers

---

## 📁 Code Structure

**Backend:** `domain/` (models, repos) → `application/` (services) → `infrastructure/` (JPA, REST)

**Frontend Shared:** `front_shared/lib/src/`

- `domain/models/` - Domain entities
- `domain/validation/` - Business rule validators (e.g., weight cannot be negative, valid date ranges)
- `data/local/` - Drift database + DAOs
- `data/remote/` - Dio API client + DTOs
- `data/repositories/` - Repository implementations
- `sync/` - SyncManager, SyncQueue, NetworkMonitor
- `auth/` - AuthService, SecureStorage
- `providers/` - Riverpod providers

**Frontend Apps:** `features/` (screens + controllers) + `widgets/` (reusable UI)

## 🎯 Next Steps

1. **Review** this document and `/datamodel.md`
2. **Set up** PostgreSQL + Flutter SDK
3. **Start Phase 1** - Create database schemas with sync metadata
4. **Test** each phase with offline scenarios
5. **Reference** `/back/CLAUDE.md` for hexagonal architecture patterns
