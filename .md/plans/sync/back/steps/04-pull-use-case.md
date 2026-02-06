# Step 4: Pull Sync Use Case

## Objective
Implement the pull sync application logic that fetches entities for a user based on lastSyncTime.

## Files to Create

### 1. Pull Request/Response DTOs

**File:** `src/main/java/com/liftlogger/application/sync/dto/PullSyncRequest.java`

```java
package com.liftlogger.application.sync.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Request for pulling entities from server
 *
 * @param entityTypes List of entity types to pull (e.g., ["TrainingPlan", "SetSession"])
 * @param lastSyncTime Optional timestamp - only fetch entities updated after this time
 */
public record PullSyncRequest(
    List<String> entityTypes,
    LocalDateTime lastSyncTime  // null means fetch all
) {
    public boolean isFullSync() {
        return lastSyncTime == null;
    }
}
```

**File:** `src/main/java/com/liftlogger/application/sync/dto/PullSyncResponse.java`

```java
package com.liftlogger.application.sync.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Response containing pulled entities grouped by type
 *
 * @param entities Map of entityType -> list of entities
 * @param syncTimestamp Server timestamp to use for next sync
 * @param totalEntities Total count of entities pulled
 */
public record PullSyncResponse(
    Map<String, List<Object>> entities,
    LocalDateTime syncTimestamp,
    int totalEntities
) {}
```

### 2. Pull Use Case Interface (Port)

**File:** `src/main/java/com/liftlogger/application/sync/PullSyncUseCase.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.dto.PullSyncRequest;
import com.liftlogger.application.sync.dto.PullSyncResponse;

import java.util.UUID;

/**
 * Use case port for pulling entities from server
 */
public interface PullSyncUseCase {

    /**
     * Pull entities for a user based on lastSyncTime
     *
     * @param userId The user requesting the sync
     * @param request The pull sync request with entity types and lastSyncTime
     * @return Response containing entities grouped by type
     */
    PullSyncResponse pullEntities(UUID userId, PullSyncRequest request);
}
```

### 3. Pull Use Case Implementation

**File:** `src/main/java/com/liftlogger/application/sync/PullSyncService.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.dto.PullSyncRequest;
import com.liftlogger.application.sync.dto.PullSyncResponse;
import com.liftlogger.domain.repository.GenericSyncRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service implementation for pull sync use case
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PullSyncService implements PullSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final RepositoryProvider repositoryProvider;

    @Override
    @Transactional(readOnly = true)
    public PullSyncResponse pullEntities(UUID userId, PullSyncRequest request) {
        log.info("Pull sync requested for user {} with {} entity types, lastSyncTime={}",
            userId, request.entityTypes().size(), request.lastSyncTime());

        LocalDateTime syncTimestamp = LocalDateTime.now();
        Map<String, List<Object>> entitiesMap = new ConcurrentHashMap<>();

        // Process entity types in parallel
        List<CompletableFuture<Void>> futures = request.entityTypes().stream()
            .map(entityType -> CompletableFuture.runAsync(() -> {
                List<Object> entities = fetchEntitiesForType(
                    entityType,
                    userId,
                    request.lastSyncTime()
                );
                if (!entities.isEmpty()) {
                    entitiesMap.put(entityType, entities);
                }
            }))
            .toList();

        // Wait for all queries to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();

        int totalEntities = entitiesMap.values().stream()
            .mapToInt(List::size)
            .sum();

        log.info("Pull sync completed for user {}: {} entities across {} types",
            userId, totalEntities, entitiesMap.size());

        return new PullSyncResponse(entitiesMap, syncTimestamp, totalEntities);
    }

    private List<Object> fetchEntitiesForType(
        String entityType,
        UUID userId,
        LocalDateTime lastSyncTime
    ) {
        try {
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            GenericSyncRepository<?> repository = repositoryProvider.getRepository(
                metadata.entityClass()
            );

            List<?> entities;
            if (lastSyncTime == null) {
                // Full sync - fetch all entities
                entities = repository.findByOwner(userId);
            } else {
                // Incremental sync - fetch only updated entities
                entities = repository.findByOwnerAndUpdatedAfter(userId, lastSyncTime);
            }

            log.debug("Fetched {} entities of type {} for user {}",
                entities.size(), entityType, userId);

            return new ArrayList<>(entities);

        } catch (Exception e) {
            log.error("Error fetching entities of type {} for user {}",
                entityType, userId, e);
            // Return empty list instead of failing entire sync
            return List.of();
        }
    }
}
```

### 4. Repository Provider

**File:** `src/main/java/com/liftlogger/application/sync/RepositoryProvider.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.domain.repository.GenericSyncRepository;

/**
 * Provider interface for getting repository instances by entity class.
 * Implementation will be in infrastructure layer.
 */
public interface RepositoryProvider {

    /**
     * Get repository for entity class
     *
     * @param entityClass The domain entity class
     * @return Repository instance for that entity
     */
    <T> GenericSyncRepository<T> getRepository(Class<T> entityClass);
}
```

## Testing

**File:** `src/test/java/com/liftlogger/application/sync/PullSyncServiceTest.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.dto.PullSyncRequest;
import com.liftlogger.application.sync.dto.PullSyncResponse;
import com.liftlogger.application.sync.validation.NoOpValidator;
import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.domain.repository.GenericSyncRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PullSyncServiceTest {

    @Mock
    private RepositoryProvider repositoryProvider;

    @Mock
    private GenericSyncRepository<TrainingPlan> trainingPlanRepository;

    private EntityRegistry entityRegistry;
    private PullSyncService pullSyncService;

    @BeforeEach
    void setUp() {
        entityRegistry = new EntityRegistry();
        entityRegistry.register(TrainingPlan.class, "athleteId", new NoOpValidator<>());

        pullSyncService = new PullSyncService(entityRegistry, repositoryProvider);
    }

    @Test
    void pullEntities_fullSync_returnsAllEntities() {
        UUID userId = UUID.randomUUID();
        TrainingPlan plan1 = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Plan 1")
            .build();
        TrainingPlan plan2 = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Plan 2")
            .build();

        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
        when(trainingPlanRepository.findByOwner(userId))
            .thenReturn(List.of(plan1, plan2));

        PullSyncRequest request = new PullSyncRequest(List.of("TrainingPlan"), null);
        PullSyncResponse response = pullSyncService.pullEntities(userId, request);

        assertThat(response.totalEntities()).isEqualTo(2);
        assertThat(response.entities()).containsKey("TrainingPlan");
        assertThat(response.entities().get("TrainingPlan")).hasSize(2);
        assertThat(response.syncTimestamp()).isNotNull();
    }

    @Test
    void pullEntities_incrementalSync_returnsOnlyUpdatedEntities() {
        UUID userId = UUID.randomUUID();
        LocalDateTime lastSyncTime = LocalDateTime.now().minusHours(1);

        TrainingPlan recentPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Recent Plan")
            .updatedAt(LocalDateTime.now())
            .build();

        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
        when(trainingPlanRepository.findByOwnerAndUpdatedAfter(eq(userId), any()))
            .thenReturn(List.of(recentPlan));

        PullSyncRequest request = new PullSyncRequest(
            List.of("TrainingPlan"),
            lastSyncTime
        );
        PullSyncResponse response = pullSyncService.pullEntities(userId, request);

        assertThat(response.totalEntities()).isEqualTo(1);
        assertThat(response.entities().get("TrainingPlan")).hasSize(1);
    }

    @Test
    void pullEntities_noEntities_returnsEmptyResponse() {
        UUID userId = UUID.randomUUID();

        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
        when(trainingPlanRepository.findByOwner(userId))
            .thenReturn(List.of());

        PullSyncRequest request = new PullSyncRequest(List.of("TrainingPlan"), null);
        PullSyncResponse response = pullSyncService.pullEntities(userId, request);

        assertThat(response.totalEntities()).isZero();
        assertThat(response.entities()).isEmpty();
    }
}
```

## Acceptance Criteria

- ✅ `PullSyncRequest` DTO with entity types and optional lastSyncTime
- ✅ `PullSyncResponse` DTO with entities grouped by type
- ✅ `PullSyncUseCase` interface (port)
- ✅ `PullSyncService` implementation with parallel queries
- ✅ `RepositoryProvider` interface for repository lookup
- ✅ Full sync (lastSyncTime=null) fetches all entities
- ✅ Incremental sync (lastSyncTime set) fetches only updated entities
- ✅ Parallel processing for multiple entity types
- ✅ Graceful error handling (one entity type failure doesn't fail entire sync)
- ✅ Unit tests pass

## Next Step

After completing this step, move to **05-push-use-case.md** to implement the push sync logic with validation.
