# Step 11: Performance Optimization

## Objective
Optimize the sync system for production scale with batching, parallel processing, caching, and database indexing.

## Optimization Areas

1. **Database Indexing** - Optimize queries
2. **Batch Processing** - Efficient bulk operations
3. **Parallel Queries** - Concurrent entity fetching
4. **Connection Pooling** - Optimize database connections
5. **Caching** - Reduce database load
6. **Query Optimization** - N+1 problem prevention

## Files to Create/Update

### 1. Database Indexes

**File:** `src/main/resources/db/migration/V002__add_sync_indexes.sql`

```sql
-- Indexes for sync queries (owner + updatedAt)
CREATE INDEX idx_training_plan_sync ON training_plans(athlete_id, updated_at);
CREATE INDEX idx_set_session_sync ON set_sessions(athlete_id, updated_at);
CREATE INDEX idx_exercise_sync ON exercises(coach_id, updated_at);
CREATE INDEX idx_workout_sync ON workouts(athlete_id, updated_at);
CREATE INDEX idx_progress_photo_sync ON progress_photos(athlete_id, updated_at);
CREATE INDEX idx_body_measurement_sync ON body_measurements(athlete_id, updated_at);
CREATE INDEX idx_nutrition_log_sync ON nutrition_logs(athlete_id, updated_at);

-- Indexes for foreign key lookups (validation)
CREATE INDEX idx_set_session_exercise ON set_sessions(exercise_id);
CREATE INDEX idx_set_session_plan ON set_sessions(training_plan_id);
CREATE INDEX idx_exercise_muscle_group ON exercises(primary_muscle_group_id);
CREATE INDEX idx_exercise_equipment ON exercises(equipment_id);
CREATE INDEX idx_exercise_category ON exercises(category_id);

-- Index for overlapping plan queries
CREATE INDEX idx_training_plan_dates ON training_plans(athlete_id, start_date, end_date);

-- Composite indexes for common query patterns
CREATE INDEX idx_set_session_athlete_date ON set_sessions(athlete_id, session_date);
CREATE INDEX idx_progress_photo_athlete_date ON progress_photos(athlete_id, taken_date);
```

### 2. Enhanced Batch Configuration

**File:** `src/main/java/com/liftlogger/infrastructure/config/JpaConfiguration.java`

```java
package com.liftlogger.infrastructure.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import javax.sql.DataSource;
import org.springframework.boot.autoconfigure.orm.jpa.HibernatePropertiesCustomizer;
import org.springframework.context.annotation.Bean;

@Configuration
@EnableJpaRepositories(basePackages = "com.liftlogger.infrastructure.persistence")
@EnableTransactionManagement
public class JpaConfiguration {

    @Bean
    public HibernatePropertiesCustomizer hibernatePropertiesCustomizer() {
        return hibernateProperties -> {
            // Batch processing
            hibernateProperties.put("hibernate.jdbc.batch_size", 50);
            hibernateProperties.put("hibernate.order_inserts", true);
            hibernateProperties.put("hibernate.order_updates", true);
            hibernateProperties.put("hibernate.batch_versioned_data", true);

            // Query optimization
            hibernateProperties.put("hibernate.jdbc.fetch_size", 100);
            hibernateProperties.put("hibernate.default_batch_fetch_size", 16);

            // Second-level cache (optional)
            hibernateProperties.put("hibernate.cache.use_second_level_cache", false);
            hibernateProperties.put("hibernate.cache.use_query_cache", false);

            // Connection pool
            hibernateProperties.put("hibernate.connection.provider_disables_autocommit", true);
        };
    }
}
```

### 3. Optimized Generic JPA Adapter

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/adapter/GenericJpaSyncAdapter.java` (update)

```java
@Override
public List<D> saveAll(List<D> entities) {
    if (entities.isEmpty()) {
        return entities;
    }

    List<J> jpaEntities = entities.stream()
        .map(this::toJpa)
        .toList();

    int batchSize = 50;
    List<J> savedEntities = new ArrayList<>(jpaEntities.size());

    // Process in batches
    for (int i = 0; i < jpaEntities.size(); i++) {
        J jpaEntity = jpaEntities.get(i);

        // Use persist for new entities, merge for existing
        if (jpaEntity.getId() == null || !existsById(jpaEntity.getId())) {
            entityManager.persist(jpaEntity);
        } else {
            jpaEntity = entityManager.merge(jpaEntity);
        }

        savedEntities.add(jpaEntity);

        // Flush and clear every batch
        if ((i + 1) % batchSize == 0 || i == jpaEntities.size() - 1) {
            entityManager.flush();
            entityManager.clear();
        }
    }

    // Return domain entities (timestamps updated)
    return toDomainList(savedEntities);
}

@Override
public List<D> findByOwnerAndUpdatedAfter(UUID ownerId, LocalDateTime lastSyncTime) {
    CriteriaBuilder cb = entityManager.getCriteriaBuilder();
    CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
    Root<J> root = query.from(getJpaEntityClass());

    Predicate ownerPredicate = cb.equal(root.get(getOwnerFieldName()), ownerId);
    Predicate updatedPredicate = cb.greaterThan(root.get("updatedAt"), lastSyncTime);

    query.where(cb.and(ownerPredicate, updatedPredicate));
    query.orderBy(cb.asc(root.get("updatedAt")));

    // Use fetch size for large result sets
    List<J> results = entityManager.createQuery(query)
        .setHint("org.hibernate.fetchSize", 100)
        .setHint("org.hibernate.readOnly", true)  // Read-only optimization
        .getResultList();

    return toDomainList(results);
}
```

### 4. Parallel Pull Sync with CompletableFuture

**File:** `src/main/java/com/liftlogger/application/sync/PullSyncService.java` (update)

```java
@Service
@RequiredArgsConstructor
public class PullSyncService implements PullSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final RepositoryProvider repositoryProvider;
    private final Executor syncExecutor;  // Custom executor for parallel queries

    @Override
    @Transactional(readOnly = true)
    public PullSyncResponse pullEntities(UUID userId, PullSyncRequest request) {
        log.info("Pull sync requested for user {} with {} entity types",
            userId, request.entityTypes().size());

        LocalDateTime syncTimestamp = LocalDateTime.now();
        Map<String, List<Object>> entitiesMap = new ConcurrentHashMap<>();

        // Process entity types in parallel
        List<CompletableFuture<Void>> futures = request.entityTypes().stream()
            .map(entityType -> CompletableFuture.runAsync(() -> {
                try {
                    List<Object> entities = fetchEntitiesForType(
                        entityType,
                        userId,
                        request.lastSyncTime()
                    );
                    if (!entities.isEmpty()) {
                        entitiesMap.put(entityType, entities);
                    }
                } catch (Exception e) {
                    log.error("Error fetching entities of type {}", entityType, e);
                    // Continue with other entity types
                }
            }, syncExecutor))
            .toList();

        // Wait for all queries to complete with timeout
        try {
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                .get(30, TimeUnit.SECONDS);
        } catch (TimeoutException e) {
            log.error("Pull sync timed out for user {}", userId);
            throw new RuntimeException("Sync operation timed out", e);
        } catch (InterruptedException | ExecutionException e) {
            log.error("Pull sync failed for user {}", userId, e);
            throw new RuntimeException("Sync operation failed", e);
        }

        int totalEntities = entitiesMap.values().stream()
            .mapToInt(List::size)
            .sum();

        log.info("Pull sync completed for user {}: {} entities across {} types in {}ms",
            userId, totalEntities, entitiesMap.size(),
            Duration.between(syncTimestamp, LocalDateTime.now()).toMillis());

        return new PullSyncResponse(entitiesMap, syncTimestamp, totalEntities);
    }
}
```

### 5. Custom Executor Configuration

**File:** `src/main/java/com/liftlogger/application/config/AsyncConfiguration.java`

```java
package com.liftlogger.application.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;

@Configuration
public class AsyncConfiguration {

    @Bean(name = "syncExecutor")
    public Executor syncExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();

        // Core pool size: number of threads to keep alive
        executor.setCorePoolSize(4);

        // Max pool size: maximum number of threads
        executor.setMaxPoolSize(12);

        // Queue capacity: queue size for pending tasks
        executor.setQueueCapacity(100);

        // Thread name prefix
        executor.setThreadNamePrefix("sync-");

        // Rejection policy: what to do when queue is full
        executor.setRejectedExecutionHandler(
            new java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy()
        );

        // Wait for tasks to complete on shutdown
        executor.setWaitForTasksToCompleteOnShutdown(true);
        executor.setAwaitTerminationSeconds(60);

        executor.initialize();
        return executor;
    }
}
```

### 6. Connection Pool Configuration

**File:** `src/main/resources/application.yml` (update)

```yaml
spring:
  datasource:
    hikari:
      # Connection pool size
      maximum-pool-size: 20
      minimum-idle: 5

      # Connection timeout
      connection-timeout: 30000  # 30 seconds
      idle-timeout: 600000       # 10 minutes
      max-lifetime: 1800000      # 30 minutes

      # Connection testing
      connection-test-query: SELECT 1
      validation-timeout: 5000

      # Leak detection (development only)
      leak-detection-threshold: 60000  # 60 seconds

      # Pool name
      pool-name: LiftLoggerHikariPool

  jpa:
    properties:
      hibernate:
        # Query optimization
        jdbc:
          batch_size: 50
          fetch_size: 100
        order_inserts: true
        order_updates: true
        batch_versioned_data: true

        # Connection management
        connection:
          provider_disables_autocommit: true

        # Query plan cache
        query:
          plan_cache_max_size: 2048
          plan_parameter_metadata_max_size: 256
```

### 7. Sync Metrics (Monitoring)

**File:** `src/main/java/com/liftlogger/application/sync/SyncMetrics.java`

```java
package com.liftlogger.application.sync;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.Duration;

/**
 * Metrics for sync operations
 */
@Component
@RequiredArgsConstructor
public class SyncMetrics {

    private final MeterRegistry meterRegistry;

    public void recordPullSync(int entityCount, Duration duration) {
        Counter.builder("sync.pull.entities")
            .description("Number of entities pulled")
            .register(meterRegistry)
            .increment(entityCount);

        Timer.builder("sync.pull.duration")
            .description("Duration of pull sync operation")
            .register(meterRegistry)
            .record(duration);
    }

    public void recordPushSync(int successCount, int failureCount, Duration duration) {
        Counter.builder("sync.push.success")
            .description("Number of entities successfully pushed")
            .register(meterRegistry)
            .increment(successCount);

        Counter.builder("sync.push.failure")
            .description("Number of entities failed to push")
            .register(meterRegistry)
            .increment(failureCount);

        Timer.builder("sync.push.duration")
            .description("Duration of push sync operation")
            .register(meterRegistry)
            .record(duration);
    }

    public void recordValidationFailure(String entityType) {
        Counter.builder("sync.validation.failure")
            .tag("entity_type", entityType)
            .description("Number of validation failures by entity type")
            .register(meterRegistry)
            .increment();
    }
}
```

## Performance Benchmarks

### Target Performance

| Operation | Entity Count | Target Time | Notes |
|-----------|--------------|-------------|-------|
| Pull Sync | 100 entities | < 500ms | Per entity type |
| Pull Sync | 1,000 entities | < 2s | Per entity type |
| Pull Sync | 10,000 entities | < 10s | Per entity type |
| Push Sync | 100 entities | < 1s | With validation |
| Push Sync | 500 entities | < 3s | With validation |
| Push Sync | 1,000 entities | < 5s | With validation |

### Load Testing Script

**File:** `scripts/load-test-sync.sh`

```bash
#!/bin/bash

# Load test script for sync endpoints
# Requires: apache-bench (ab)

BASE_URL="http://localhost:8080/api/v1/sync"
AUTH_TOKEN="Bearer your-jwt-token"

# Test pull sync
echo "Testing pull sync..."
ab -n 100 -c 10 \
   -H "Authorization: $AUTH_TOKEN" \
   -H "Content-Type: application/json" \
   -p pull-request.json \
   "$BASE_URL/pull"

# Test push sync
echo "Testing push sync..."
ab -n 100 -c 10 \
   -H "Authorization: $AUTH_TOKEN" \
   -H "Content-Type: application/json" \
   -p push-request.json \
   "$BASE_URL/push"
```

## Acceptance Criteria

- ✅ Database indexes created for all sync queries
- ✅ Batch processing configured (batch size: 50)
- ✅ Parallel queries implemented with CompletableFuture
- ✅ Connection pool optimized (HikariCP)
- ✅ Custom executor for parallel sync operations
- ✅ Metrics collection for monitoring
- ✅ Performance benchmarks documented
- ✅ Load testing script created
- ✅ Query hints for fetch size and read-only
- ✅ Timeout handling for long-running operations

## Performance Monitoring

Monitor these metrics in production:

1. **Query Performance**
   - Average query time by entity type
   - Slow query log (> 1s)

2. **Sync Operations**
   - Pull sync duration
   - Push sync duration
   - Entities per sync operation

3. **Database**
   - Connection pool utilization
   - Query cache hit rate
   - Index usage statistics

4. **Validation**
   - Validation failure rate by entity type
   - Validation duration

## Next Step

After completing this step, move to **12-documentation.md** to create API documentation and usage guides.
