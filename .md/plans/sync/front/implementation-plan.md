# LiftLogger Frontend Offline-First Sync - Implementation Plan

## Context
Offline-first Flutter sync for LiftLogger. Gyms have poor connectivity - all data in local Drift DB, syncs to PostgreSQL when online. Client-wins conflict resolution, optimistic updates, client UUIDs, exponential backoff retry. **Projects**: front_shared (package), front_athlete/coach (apps). **Flow**: User action → Local DB (isDirty=true) → UI updates → Sync (PULL→PUSH→RETRY)

## Dependencies (front_shared/pubspec.yaml)
```yaml
dependencies: drift: ^2.20.0, dio: ^5.4.0, flutter_riverpod: ^2.5.1, flutter_secure_storage: ^9.0.0, connectivity_plus: ^5.0.2, uuid: ^4.3.3, freezed_annotation: ^2.4.1, json_annotation: ^4.8.1
dev_dependencies: build_runner: ^2.4.8, drift_dev: ^2.20.0, freezed: ^2.4.7, mockito: ^5.4.4, json_serializable: ^6.7.1
```

## Structure (front_shared/lib/src/)
**domain/models/** - base/syncable_entity.dart, training_plan.dart (+11 entities) | **domain/repositories/** - training_plan_repository.dart (+11) | **data/local/database/tables/** - base_table.dart, training_plans_table.dart (+11) | **data/local/database/daos/** - base_dao.dart, training_plan_dao.dart (+11) | **data/local/database/** - app_database.dart | **data/local/secure_storage/** - secure_storage_service.dart | **data/remote/** - api_client.dart, sync_api_service.dart, auth_api_service.dart | **data/remote/dto/** - sync_pull/push DTOs | **data/repositories/** - training_plan_repository_impl.dart (+11) | **sync/core/** - sync_manager.dart, sync_queue.dart, sync_state.dart, entity_registry.dart | **sync/strategies/** - pull_strategy.dart, push_strategy.dart, conflict_resolver.dart | **auth/** - auth_service.dart, auth_state.dart | **providers/** - database/network/repository/sync/auth_providers.dart | **core/network/** - network_info.dart, network_info_impl.dart

## 1. base_table.dart - ALL 12 tables extend this
```dart
mixin SyncableTable on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  @override Set<Column> get primaryKey => {id};
}
```

## 2. training_plans_table.dart - Example
```dart
@DataClassName('TrainingPlanData')
class TrainingPlans extends Table with SyncableTable {
  TextColumn get athleteId => text().references(Athletes, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  DateTimeColumn get date => dateTime()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}
@TableIndex(name: 'idx_training_plans_athlete', columns: {#athleteId})
@TableIndex(name: 'idx_training_plans_dirty', columns: {#isDirty, #athleteId})
class TrainingPlansIndex extends TrainingPlans {}
```

## 3. training_plan.dart - Domain Model
```dart
@freezed
class TrainingPlan with _$TrainingPlan implements SyncableEntity {
  const factory TrainingPlan({required String id, required String athleteId, required String name, required DateTime date,
    required bool isLocked, required DateTime createdAt, required DateTime updatedAt, required int version,
    DateTime? deletedAt, @Default(false) bool isDirty, DateTime? lastSyncedAt}) = _TrainingPlan;
  factory TrainingPlan.fromJson(Map<String, dynamic> json) => _$TrainingPlanFromJson(json);
  const TrainingPlan._();
  factory TrainingPlan.create({required String athleteId, required String name, required DateTime date, bool isLocked = false}) {
    final now = DateTime.now();
    return TrainingPlan(id: Uuid().v4(), athleteId: athleteId, name: name, date: date, isLocked: isLocked,
      createdAt: now, updatedAt: now, version: 1, isDirty: true);
  }
  TrainingPlan markDirty() => copyWith(isDirty: true, updatedAt: DateTime.now());
  TrainingPlan softDelete() => copyWith(deletedAt: DateTime.now(), isDirty: true, updatedAt: DateTime.now());
}
```

## 4. base_dao.dart
```dart
abstract class BaseDao<T extends Table, D> extends DatabaseAccessor<AppDatabase> {
  TableInfo<T, D> get table;
  Future<D?> findById(String id);
  Future<List<D>> findAllActive();
  Future<List<D>> findAllDirty();
  Future<void> markDirty(String id);
  Future<void> clearDirty(String id, DateTime syncedAt);
  Future<void> upsertFromServer(D entity);
  Future<void> softDelete(String id);
}
```

## 5. training_plan_dao.dart
```dart
@DriftAccessor(tables: [TrainingPlans])
class TrainingPlanDao extends BaseDao<TrainingPlans, TrainingPlanData> with _$TrainingPlanDaoMixin {
  TrainingPlanDao(AppDatabase db) : super(db);
  @override TableInfo<TrainingPlans, TrainingPlanData> get table => trainingPlans;
  @override Future<TrainingPlanData?> findById(String id) => (select(trainingPlans)..where((t) => t.id.equals(id))).getSingleOrNull();
  @override Future<List<TrainingPlanData>> findAllDirty() => (select(trainingPlans)..where((t) => t.isDirty.equals(true))).get();
  @override Future<void> clearDirty(String id, DateTime syncedAt) => (update(trainingPlans)..where((t) => t.id.equals(id)))
    .write(TrainingPlansCompanion(isDirty: Value(false), lastSyncedAt: Value(syncedAt)));
  @override Future<void> upsertFromServer(TrainingPlanData entity) => into(trainingPlans).insertOnConflictUpdate(entity);
  Future<String> create(TrainingPlan plan) async {
    await into(trainingPlans).insert(TrainingPlansCompanion.insert(id: Value(plan.id), athleteId: plan.athleteId,
      name: plan.name, date: plan.date, isLocked: Value(plan.isLocked), isDirty: Value(true)));
    return plan.id;
  }
  TrainingPlan toDomain(TrainingPlanData d) => TrainingPlan(id: d.id, athleteId: d.athleteId, name: d.name, date: d.date,
    isLocked: d.isLocked, createdAt: d.createdAt, updatedAt: d.updatedAt, version: d.version, deletedAt: d.deletedAt,
    isDirty: d.isDirty, lastSyncedAt: d.lastSyncedAt);
}
```

## 6. sync_manager.dart - Orchestrator (PULL→PUSH→RETRY)
```dart
class SyncManager {
  final PullStrategy _pullStrategy; final PushStrategy _pushStrategy; final SyncQueue _syncQueue;
  final _stateController = StreamController<SyncState>.broadcast();
  Stream<SyncState> get state => _stateController.stream;
  bool _isSyncing = false;
  Future<SyncResult> sync({String? athleteId, DateTime? since}) async {
    if (_isSyncing) return SyncResult.failure(message: 'Sync in progress', error: null, timestamp: DateTime.now());
    _isSyncing = true; _stateController.add(SyncState.syncing(phase: 'Pulling'));
    try {
      final pullCount = await _pullStrategy.execute(athleteId: athleteId ?? await _getCurrentAthleteId(), since: since);
      _stateController.add(SyncState.syncing(phase: 'Pushing'));
      final pushResult = await _pushStrategy.execute();
      await _processRetryQueue();
      _stateController.add(SyncState.completed(pushResult));
      return pushResult;
    } catch (e) {
      _stateController.add(SyncState.error(e.toString()));
      return SyncResult.failure(message: e.toString(), error: e, timestamp: DateTime.now());
    } finally { _isSyncing = false; }
  }
}
```

## 7. entity_registry.dart - Generic DAO/Mapper Registry
```dart
// Maps entity types to DAOs and serialization functions
class EntityRegistry {
  final Map<String, BaseDao> _daoMap = {};
  final Map<String, Function(Map<String, dynamic>)> _deserializers = {};
  final Map<String, Function(dynamic)> _serializers = {};

  void register<T extends Table, D>({
    required String entityType,
    required BaseDao<T, D> dao,
    required D Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> Function(D) toJson,
  }) {
    _daoMap[entityType] = dao;
    _deserializers[entityType] = fromJson;
    _serializers[entityType] = toJson;
  }

  BaseDao? getDao(String entityType) => _daoMap[entityType];
  D? deserialize<D>(String entityType, Map<String, dynamic> json) => _deserializers[entityType]?.call(json) as D?;
  Map<String, dynamic>? serialize(String entityType, dynamic data) => _serializers[entityType]?.call(data);

  Future<List<Map<String, dynamic>>> getAllDirtyEntities() async {
    final dirtyEntities = <Map<String, dynamic>>[];
    for (final entry in _daoMap.entries) {
      final entityType = entry.key; final dao = entry.value;
      final dirty = await dao.findAllDirty();
      for (final data in dirty) {
        final json = serialize(entityType, data);
        if (json != null) dirtyEntities.add({'_type': entityType, ...json});
      }
    }
    return dirtyEntities;
  }
}

// Setup in app initialization
void setupRegistry(EntityRegistry registry, AppDatabase db) {
  registry.register(entityType: 'TrainingPlan', dao: db.trainingPlanDao,
    fromJson: (json) => TrainingPlanData.fromJson(json), toJson: (data) => (data as TrainingPlanData).toJson());
  registry.register(entityType: 'User', dao: db.userDao,
    fromJson: (json) => UserData.fromJson(json), toJson: (data) => (data as UserData).toJson());
  // ... register other 9 entities
}
```

## 8. pull_strategy.dart - Generic Server→Local Merge
```dart
class PullStrategy {
  final EntityRegistry _registry;
  Future<int> execute({required String athleteId, DateTime? since}) async {
    if (!await _networkInfo.isConnected) throw NetworkException('No connection');
    final response = await _syncApi.pull(since: since ?? DateTime.fromMillisecondsSinceEpoch(0), athleteId: athleteId);
    int merged = 0;
    for (final entry in response.changesByType.entries) {
      final entityType = entry.key; final entities = entry.value;
      final dao = _registry.getDao(entityType);
      if (dao == null) continue;  // Unknown entity type, skip
      for (final entityData in entities) {
        final deserialized = _registry.deserialize(entityType, entityData);
        if (deserialized == null) continue;
        final local = await dao.findById(entityData['id']);
        if (local == null || !(local as dynamic).isDirty) { await dao.upsertFromServer(deserialized); merged++; }
      }
    }
    return merged;
  }
}
```

## 9. push_strategy.dart - Generic Local→Server Push
```dart
class PushStrategy {
  final EntityRegistry _registry;
  Future<SyncResult> execute() async {
    if (!await _networkInfo.isConnected) throw NetworkException('No connection');
    final dirtyEntities = await _registry.getAllDirtyEntities();
    if (dirtyEntities.isEmpty) return SyncResult.success(pullCount: 0, pushCount: 0, timestamp: DateTime.now());
    final groupedByType = <String, List<Map<String, dynamic>>>{};
    for (final entity in dirtyEntities) {
      final entityType = entity['_type'] as String;
      groupedByType.putIfAbsent(entityType, () => []);
      groupedByType[entityType]!.add(Map.from(entity)..remove('_type')..remove('isDirty')..remove('lastSyncedAt'));
    }
    final response = await _syncApi.push(SyncPushRequestDto(changes: groupedByType));
    final failures = <EntityFailure>[];
    for (final success in response.succeeded) {
      final dao = _registry.getDao(success.entityType);
      if (dao != null) {
        final updated = _registry.deserialize(success.entityType, success.entity);
        if (updated != null) await dao.upsertFromServer(updated);
        await dao.clearDirty(success.entityId, DateTime.now());
      }
    }
    for (final failure in response.failed) {
      failures.add(EntityFailure(entityType: failure.entityType, entityId: failure.entityId,
        errors: failure.errors.map((e) => e.message).toList()));
      _syncQueue.enqueue(QueuedSync(id: Uuid().v4(), entityType: failure.entityType, entityId: failure.entityId,
        data: dirtyEntities.firstWhere((e) => e['id'] == failure.entityId), queuedAt: DateTime.now(), retryCount: 0,
        nextRetryAt: DateTime.now().add(Duration(seconds: 30))));
    }
    return failures.isEmpty
      ? SyncResult.success(pullCount: 0, pushCount: response.summary.succeeded, timestamp: DateTime.now())
      : SyncResult.partialSuccess(pullCount: 0, pushSuccessCount: response.summary.succeeded,
          pushFailureCount: response.summary.failed, failures: failures, timestamp: DateTime.now());
  }
}
```

## 10. auth_service.dart - Offline Auth (SHA-256 password hash)
```dart
class AuthService {
  Future<AuthState> login(String username, String password) async {
    if (await _networkInfo.isConnected) {
      final response = await _authApi.login(username, password);
      await _secureStorage.saveToken(response.token);
      await _secureStorage.savePasswordHash(_hashPassword(password));
      await _secureStorage.saveUserId(response.userId);
      await _secureStorage.saveUserType(response.userType);
      return AuthState.authenticated(userId: response.userId, userType: response.userType, token: response.token);
    } else {
      final cachedHash = await _secureStorage.getPasswordHash();
      if (cachedHash == null) return AuthState.error('Cannot login offline without previous online login');
      if (_hashPassword(password) != cachedHash) return AuthState.error('Invalid credentials');
      return AuthState.authenticated(userId: await _secureStorage.getUserId(), userType: await _secureStorage.getUserType(),
        token: await _secureStorage.getToken());
    }
  }
  String _hashPassword(String password) => sha256.convert(utf8.encode(password)).toString();
}
```

## 11. sync_queue.dart - Exponential Backoff (30s→60s→2m→4m→8m, max 5 retries)
```dart
@freezed class QueuedSync with _$QueuedSync {
  const factory QueuedSync({required String id, required String entityType, required String entityId,
    required Map<String, dynamic> data, required DateTime queuedAt, required int retryCount, required DateTime nextRetryAt}) = _QueuedSync;
  const QueuedSync._();
  bool get canRetry => retryCount < 5;
  QueuedSync incrementRetry() => copyWith(retryCount: retryCount + 1,
    nextRetryAt: DateTime.now().add(Duration(seconds: (pow(2, retryCount) * 30).toInt())));
}
class SyncQueue {
  final Queue<QueuedSync> _queue = Queue();
  void enqueue(QueuedSync sync) { if (sync.canRetry) _queue.add(sync); }
  List<QueuedSync> getDueRetries() => _queue.where((s) => s.nextRetryAt.isBefore(DateTime.now())).toList();
  void remove(String syncId) => _queue.removeWhere((s) => s.id == syncId);
}
```

## 12. API Client & DTOs
```dart
// api_client.dart
class ApiClient {
  late Dio _dio;
  ApiClient(SecureStorageService storage) {
    _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl, connectTimeout: Duration(seconds: 30)));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (opts, handler) async { final token = await storage.getToken();
        if (token != null) opts.headers['Authorization'] = 'Bearer $token'; handler.next(opts); },
      onError: (error, handler) async { if (error.response?.statusCode == 401) {
        if (await _refreshToken()) return handler.resolve(await _retry(error.requestOptions)); }
        handler.next(error); }));
  }
}
// sync_api_service.dart
class SyncApiService {
  Future<SyncPullResponseDto> pull({required DateTime since, required String athleteId, List<String>? entityTypes, int limit = 100}) async {
    final response = await _apiClient.dio.get('/api/v1/sync/pull', queryParameters: {'since': since.toIso8601String(),
      'athleteId': athleteId, if (entityTypes != null) 'entityTypes': entityTypes.join(','), 'limit': limit});
    return SyncPullResponseDto.fromJson(response.data);
  }
  Future<SyncPushResponseDto> push(SyncPushRequestDto request) async {
    final response = await _apiClient.dio.post('/api/v1/sync/push', data: request.toJson());
    return SyncPushResponseDto.fromJson(response.data);
  }
}
// DTOs (freezed + json_serializable)
@freezed class SyncPullResponseDto with _$SyncPullResponseDto {
  factory SyncPullResponseDto({required Map<String, List<Map<String, dynamic>>> changesByType, required DateTime syncTimestamp,
    required Map<String, EntityStats> stats}) = _SyncPullResponseDto;
  factory SyncPullResponseDto.fromJson(Map<String, dynamic> json) => _$SyncPullResponseDtoFromJson(json);
}
@freezed class SyncPushRequestDto with _$SyncPushRequestDto {
  factory SyncPushRequestDto({required Map<String, List<Map<String, dynamic>>> changes}) = _SyncPushRequestDto;
  factory SyncPushRequestDto.fromJson(Map<String, dynamic> json) => _$SyncPushRequestDtoFromJson(json);
}
@freezed class SyncPushResponseDto with _$SyncPushResponseDto {
  factory SyncPushResponseDto({required List<SyncSuccessDto> succeeded, required List<SyncFailureDto> failed,
    required SyncSummary summary}) = _SyncPushResponseDto;
  factory SyncPushResponseDto.fromJson(Map<String, dynamic> json) => _$SyncPushResponseDtoFromJson(json);
}
```

## 13. Riverpod Providers
```dart
// database_providers.dart
final databaseProvider = Provider<AppDatabase>((ref) { final db = AppDatabase(); ref.onDispose(() => db.close()); return db; });
final trainingPlanDaoProvider = Provider((ref) => ref.watch(databaseProvider).trainingPlanDao);
final entityRegistryProvider = Provider<EntityRegistry>((ref) {
  final registry = EntityRegistry();
  setupRegistry(registry, ref.watch(databaseProvider));
  return registry;
});
// network_providers.dart
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl(Connectivity()));
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(ref.watch(secureStorageProvider)));
final syncApiServiceProvider = Provider<SyncApiService>((ref) => SyncApiService(ref.watch(apiClientProvider)));
// sync_providers.dart
final pullStrategyProvider = Provider<PullStrategy>((ref) => PullStrategy(ref.watch(syncApiServiceProvider), ref.watch(networkInfoProvider), ref.watch(entityRegistryProvider)));
final pushStrategyProvider = Provider<PushStrategy>((ref) => PushStrategy(ref.watch(syncApiServiceProvider), ref.watch(networkInfoProvider), ref.watch(syncQueueProvider), ref.watch(entityRegistryProvider)));
final syncManagerProvider = Provider<SyncManager>((ref) {
  final mgr = SyncManager(ref.watch(pullStrategyProvider), ref.watch(pushStrategyProvider), ref.watch(networkInfoProvider), ref.watch(syncQueueProvider));
  mgr.startRetryTimer(); ref.onDispose(() => mgr.dispose()); return mgr;
});
final syncStateProvider = StreamProvider((ref) => ref.watch(syncManagerProvider).state);
// repository_providers.dart
final trainingPlanRepositoryProvider = Provider<TrainingPlanRepository>((ref) => TrainingPlanRepositoryImpl(ref.watch(trainingPlanDaoProvider)));
```

## 14. app_database.dart
```dart
@DriftDatabase(tables: [TrainingPlans, Athletes, Coaches, Exercises, Variants, ExercisePlans, SetPlans, TrainingSessions,
  ExerciseSessions, SetSessions, BodyWeightEntries, ExercisePlanVariants, ExerciseSessionVariants],
  daos: [TrainingPlanDao, AthleteDao, CoachDao, /* ...other 9 DAOs */ ])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  @override int get schemaVersion => 1;
  @override MigrationStrategy get migration => MigrationStrategy(onCreate: (m) async => await m.createAll());
}
LazyDatabase _openConnection() => LazyDatabase(() async {
  final dbFolder = await getApplicationDocumentsDirectory();
  return NativeDatabase(File(p.join(dbFolder.path, 'liftlogger.db')));
});
```

## Extending to 11 Other Entities (1-2hrs each)
**Pattern**: 1) Domain model (copy TrainingPlan, impl SyncableEntity, @freezed, add fields) 2) Table (class X extends Table with SyncableTable + indexes) 3) DAO (extend BaseDao, impl findById/findAllDirty/clearDirty/upsertFromServer, add toJson/fromJson to Drift data class) 4) Repository (interface in domain/, impl in data/) 5) **Register in EntityRegistry** (registry.register(entityType: 'X', dao: db.xDao, fromJson: XData.fromJson, toJson: (d) => d.toJson())) 6) DTO (if needed, usually Drift data class has toJson/fromJson) 7) Providers (daoProvider, repositoryProvider)

**Key Advantage**: No need to modify pull/push strategies - just register the entity and it automatically syncs!

## Implementation Priority
1. Base: base_table.dart, base_dao.dart, syncable_entity.dart, sync_state/result/queue models
2. API: api_client.dart, sync_api_service.dart, DTOs
3. Network: network_info_impl.dart, secure_storage_service.dart
4. Registry: entity_registry.dart (generic DAO/mapper registry)
5. Example: TrainingPlan (model, table, DAO with toJson/fromJson, repo) - pattern for 11 others
6. Strategies: pull_strategy.dart, push_strategy.dart (now using registry - no switch statements!)
7. Orchestrator: sync_manager.dart
8. Auth: auth_service.dart, auth_state.dart
9. Database: app_database.dart, providers (including entityRegistryProvider)
10. Tests: sync_manager, pull/push strategies, registry
11. Extend to 11 entities (just register in setupRegistry!)

## Testing
```bash
cd front_shared && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```
**E2E Test**:
```dart
final plan = TrainingPlan.create(athleteId: 'test', name: 'Plan', date: DateTime.now());
await repository.create(plan);  // isDirty=true
expect((await repository.findById(plan.id))?.isDirty, isTrue);
await syncManager.sync(athleteId: 'test');  // PULL→PUSH→RETRY
final synced = await repository.findById(plan.id);
expect(synced?.isDirty, isFalse);
expect(synced?.lastSyncedAt, isNotNull);
```
**Unit**: `flutter test test/sync/` - SyncManager (pull→push→retry), ConflictResolver (client wins), PullStrategy (merge), PushStrategy (partial failures, queue)

## Success Criteria
✅ Offline create→isDirty=true | Sync→isDirty=false, lastSyncedAt set | No data loss on partial failures
✅ Local dirty overwrites server (client wins) | Clean local accepts server
✅ Failed entities queued, exponential backoff (30s→60s→2m→4m→8m), max 5 retries
✅ Offline auth: online login caches token+hash, offline validates hash
✅ Performance: 100 entities <5s local, <2s API | Indexes on athleteId, updatedAt, isDirty
✅ Extensibility: new entity <2hrs following TrainingPlan pattern

## Code Gen
`dart run build_runner watch --delete-conflicting-outputs` (auto-regen Drift, Freezed, JSON)

## Error Handling
**Network**: SyncResult.failure, offline indicator, auto-retry on reconnect | **Validation(400)**: Keep dirty, queue retry, show errors | **Auth(401)**: Refresh token, retry | **Server(500)**: Queue retry | **DB**: Log, don't clear dirty

## Performance
**Indexes**: `@TableIndex(columns: {#athleteId})`, `@TableIndex(columns: {#isDirty})` on all tables | **Batching**: Drift transactions, pull upserts 100/type, push groups by type | **Pagination**: limit=100 (max 500), check stats.hasMore

## Rollout
1. Foundation 2. TrainingPlan E2E 3. Unit+integration tests 4. Extend to 11 entities 5. Offline auth 6. UI sync indicators 7. Performance testing (1000+ entities)

**Refs**: `.md/plans/sync/back/pull-push-api.md`, `.md/plans/plan-small.md`, `.md/plans/datamodel.md`
