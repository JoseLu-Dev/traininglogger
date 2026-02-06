# Step 5: Push Sync Use Case

## Objective
Implement the push sync application logic that validates and saves entities, returning partial failures for invalid entities.

## Files to Create

### 1. Push Request/Response DTOs

**File:** `src/main/java/com/liftlogger/application/sync/dto/PushSyncRequest.java`

```java
package com.liftlogger.application.sync.dto;

import java.util.List;
import java.util.Map;

/**
 * Request for pushing entities to server
 * Frontend groups entities by type for cleaner API
 *
 * @param entities Map of entityType -> list of entities
 */
public record PushSyncRequest(
    Map<String, List<Object>> entities
) {
    public int getTotalEntities() {
        return entities.values().stream()
            .mapToInt(List::size)
            .sum();
    }
}
```

**File:** `src/main/java/com/liftlogger/application/sync/dto/PushSyncResponse.java`

```java
package com.liftlogger.application.sync.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Response after pushing entities
 *
 * @param successCount Number of entities successfully saved
 * @param failureCount Number of entities that failed validation
 * @param failures List of validation failures with entity details
 * @param syncTimestamp Server timestamp after save
 */
public record PushSyncResponse(
    int successCount,
    int failureCount,
    List<EntityFailure> failures,
    LocalDateTime syncTimestamp
) {
    public boolean hasFailures() {
        return failureCount > 0;
    }

    public boolean isFullSuccess() {
        return failureCount == 0;
    }
}
```

**File:** `src/main/java/com/liftlogger/application/sync/dto/EntityFailure.java`

```java
package com.liftlogger.application.sync.dto;

import com.liftlogger.application.sync.validation.ValidationError;

import java.util.List;
import java.util.UUID;

/**
 * Details of a failed entity validation
 *
 * @param entityType The entity type (e.g., "TrainingPlan")
 * @param entityId The entity ID that failed
 * @param errors List of validation errors
 */
public record EntityFailure(
    String entityType,
    UUID entityId,
    List<ValidationError> errors
) {}
```

### 2. Push Use Case Interface (Port)

**File:** `src/main/java/com/liftlogger/application/sync/PushSyncUseCase.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.dto.PushSyncRequest;
import com.liftlogger.application.sync.dto.PushSyncResponse;

import java.util.UUID;

/**
 * Use case port for pushing entities to server
 */
public interface PushSyncUseCase {

    /**
     * Validate and save entities for a user
     *
     * @param userId The user pushing the entities
     * @param request The push sync request with entities grouped by type
     * @return Response with success/failure counts and validation errors
     */
    PushSyncResponse pushEntities(UUID userId, PushSyncRequest request);
}
```

### 3. Push Use Case Implementation

**File:** `src/main/java/com/liftlogger/application/sync/PushSyncService.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.dto.EntityFailure;
import com.liftlogger.application.sync.dto.PushSyncRequest;
import com.liftlogger.application.sync.dto.PushSyncResponse;
import com.liftlogger.application.sync.validation.ValidationContext;
import com.liftlogger.application.sync.validation.ValidationResult;
import com.liftlogger.domain.repository.GenericSyncRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Service implementation for push sync use case
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PushSyncService implements PushSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final RepositoryProvider repositoryProvider;
    private final UserContextProvider userContextProvider;

    @Override
    @Transactional
    public PushSyncResponse pushEntities(UUID userId, PushSyncRequest request) {
        log.info("Push sync requested for user {} with {} entities",
            userId, request.getTotalEntities());

        ValidationContext validationContext = userContextProvider.getValidationContext(userId);
        List<EntityFailure> failures = new ArrayList<>();
        AtomicInteger successCount = new AtomicInteger(0);

        // Process each entity type
        request.entities().forEach((entityType, entities) -> {
            processEntityType(
                entityType,
                entities,
                validationContext,
                successCount,
                failures
            );
        });

        LocalDateTime syncTimestamp = LocalDateTime.now();
        int failureCount = failures.size();

        log.info("Push sync completed for user {}: {} succeeded, {} failed",
            userId, successCount.get(), failureCount);

        return new PushSyncResponse(
            successCount.get(),
            failureCount,
            failures,
            syncTimestamp
        );
    }

    @SuppressWarnings("unchecked")
    private void processEntityType(
        String entityType,
        List<Object> entities,
        ValidationContext validationContext,
        AtomicInteger successCount,
        List<EntityFailure> failures
    ) {
        try {
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            GenericSyncRepository repository = repositoryProvider.getRepository(
                metadata.entityClass()
            );

            List<Object> validEntities = new ArrayList<>();

            // Validate each entity
            for (Object entity : entities) {
                UUID entityId = extractEntityId(entity);
                ValidationResult result = metadata.validator().validate(
                    entity,
                    validationContext
                );

                if (result.isValid()) {
                    validEntities.add(entity);
                } else {
                    failures.add(new EntityFailure(
                        entityType,
                        entityId,
                        result.errors()
                    ));
                    log.warn("Validation failed for {} with id {}: {}",
                        entityType, entityId, result.errors());
                }
            }

            // Batch save valid entities
            if (!validEntities.isEmpty()) {
                repository.saveAll(validEntities);
                successCount.addAndGet(validEntities.size());
                log.debug("Saved {} valid entities of type {}",
                    validEntities.size(), entityType);
            }

        } catch (Exception e) {
            log.error("Error processing entity type {}", entityType, e);
            // Add all entities of this type as failures
            entities.forEach(entity -> {
                UUID entityId = extractEntityId(entity);
                failures.add(new EntityFailure(
                    entityType,
                    entityId,
                    List.of(new com.liftlogger.application.sync.validation.ValidationError(
                        "general",
                        "PROCESSING_ERROR",
                        "Error processing entity: " + e.getMessage()
                    ))
                ));
            });
        }
    }

    /**
     * Extract entity ID using reflection
     */
    private UUID extractEntityId(Object entity) {
        try {
            var method = entity.getClass().getMethod("getId");
            return (UUID) method.invoke(entity);
        } catch (Exception e) {
            log.error("Failed to extract entity ID", e);
            return null;
        }
    }
}
```

### 4. User Context Provider

**File:** `src/main/java/com/liftlogger/application/sync/UserContextProvider.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.validation.ValidationContext;

import java.util.UUID;

/**
 * Provider interface for getting user context.
 * Implementation will be in infrastructure layer (e.g., from Spring Security).
 */
public interface UserContextProvider {

    /**
     * Get validation context for user
     *
     * @param userId The user ID
     * @return Validation context with user role
     */
    ValidationContext getValidationContext(UUID userId);
}
```

## Testing

**File:** `src/test/java/com/liftlogger/application/sync/PushSyncServiceTest.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.dto.PushSyncRequest;
import com.liftlogger.application.sync.dto.PushSyncResponse;
import com.liftlogger.application.sync.validation.*;
import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.domain.repository.GenericSyncRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PushSyncServiceTest {

    @Mock
    private RepositoryProvider repositoryProvider;

    @Mock
    private UserContextProvider userContextProvider;

    @Mock
    private GenericSyncRepository<TrainingPlan> trainingPlanRepository;

    @Mock
    private EntityValidator<TrainingPlan> trainingPlanValidator;

    private EntityRegistry entityRegistry;
    private PushSyncService pushSyncService;
    private ValidationContext validationContext;

    @BeforeEach
    void setUp() {
        entityRegistry = new EntityRegistry();
        entityRegistry.register(TrainingPlan.class, "athleteId", trainingPlanValidator);

        pushSyncService = new PushSyncService(
            entityRegistry,
            repositoryProvider,
            userContextProvider
        );

        validationContext = new ValidationContext(UUID.randomUUID(), "ATHLETE");
        when(userContextProvider.getValidationContext(any()))
            .thenReturn(validationContext);
        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
    }

    @Test
    void pushEntities_allValid_savesAllEntities() {
        UUID userId = UUID.randomUUID();
        TrainingPlan plan1 = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Plan 1")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        when(trainingPlanValidator.validate(any(), any()))
            .thenReturn(ValidationResult.success());
        when(trainingPlanRepository.saveAll(anyList()))
            .thenReturn(List.of(plan1));

        PushSyncRequest request = new PushSyncRequest(
            Map.of("TrainingPlan", List.of(plan1))
        );
        PushSyncResponse response = pushSyncService.pushEntities(userId, request);

        assertThat(response.successCount()).isEqualTo(1);
        assertThat(response.failureCount()).isZero();
        assertThat(response.failures()).isEmpty();
        assertThat(response.isFullSuccess()).isTrue();

        verify(trainingPlanRepository).saveAll(anyList());
    }

    @Test
    void pushEntities_someInvalid_savesValidReturnsFailures() {
        UUID userId = UUID.randomUUID();
        TrainingPlan validPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Valid Plan")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        TrainingPlan invalidPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("")  // Invalid: empty name
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().minusDays(1))  // Invalid: end before start
            .build();

        when(trainingPlanValidator.validate(eq(validPlan), any()))
            .thenReturn(ValidationResult.success());
        when(trainingPlanValidator.validate(eq(invalidPlan), any()))
            .thenReturn(ValidationResult.failure(List.of(
                ValidationError.required("name"),
                ValidationError.invalid("endDate", "End date must be after start date")
            )));

        PushSyncRequest request = new PushSyncRequest(
            Map.of("TrainingPlan", List.of(validPlan, invalidPlan))
        );
        PushSyncResponse response = pushSyncService.pushEntities(userId, request);

        assertThat(response.successCount()).isEqualTo(1);
        assertThat(response.failureCount()).isEqualTo(1);
        assertThat(response.failures()).hasSize(1);
        assertThat(response.failures().get(0).entityId()).isEqualTo(invalidPlan.getId());
        assertThat(response.failures().get(0).errors()).hasSize(2);

        verify(trainingPlanRepository).saveAll(argThat(list -> list.size() == 1));
    }

    @Test
    void pushEntities_allInvalid_savesNothingReturnsAllFailures() {
        UUID userId = UUID.randomUUID();
        TrainingPlan invalidPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("")
            .build();

        when(trainingPlanValidator.validate(any(), any()))
            .thenReturn(ValidationResult.failure(
                ValidationError.required("name")
            ));

        PushSyncRequest request = new PushSyncRequest(
            Map.of("TrainingPlan", List.of(invalidPlan))
        );
        PushSyncResponse response = pushSyncService.pushEntities(userId, request);

        assertThat(response.successCount()).isZero();
        assertThat(response.failureCount()).isEqualTo(1);
        assertThat(response.isFullSuccess()).isFalse();

        verify(trainingPlanRepository, never()).saveAll(anyList());
    }
}
```

## Acceptance Criteria

- ✅ `PushSyncRequest` DTO with entities grouped by type
- ✅ `PushSyncResponse` DTO with success/failure counts and details
- ✅ `EntityFailure` DTO with entity ID and validation errors
- ✅ `PushSyncUseCase` interface (port)
- ✅ `PushSyncService` implementation with validation
- ✅ `UserContextProvider` interface for getting user context
- ✅ Validates each entity before saving
- ✅ Batch saves valid entities
- ✅ Returns partial failures (invalid entities don't stop sync)
- ✅ Graceful error handling per entity type
- ✅ Unit tests pass

## Next Step

After completing this step, move to **06-jpa-adapters.md** to implement the infrastructure layer with JPA repositories.
