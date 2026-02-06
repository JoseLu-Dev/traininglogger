# Step 10: Integration Testing

## Objective
Write comprehensive integration tests that verify the entire sync flow from REST API to database.

## Test Strategy

1. **Unit Tests** - Already covered in previous steps
2. **Integration Tests** - End-to-end sync flow with real database
3. **Performance Tests** - Batch processing and parallel queries
4. **Contract Tests** - API contract verification

## Files to Create

### 1. Integration Test Base Class

**File:** `src/test/java/com/liftlogger/integration/SyncIntegrationTestBase.java`

```java
package com.liftlogger.integration;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import jakarta.persistence.EntityManager;

/**
 * Base class for sync integration tests
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
public abstract class SyncIntegrationTestBase {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    @Autowired
    protected EntityManager entityManager;

    @BeforeEach
    void baseSetup() {
        // Clear data before each test
        entityManager.flush();
        entityManager.clear();
    }

    protected void flushAndClear() {
        entityManager.flush();
        entityManager.clear();
    }
}
```

### 2. Pull Sync Integration Test

**File:** `src/test/java/com/liftlogger/integration/PullSyncIntegrationTest.java`

```java
package com.liftlogger.integration;

import com.liftlogger.infrastructure.persistence.entity.TrainingPlanJpaEntity;
import com.liftlogger.infrastructure.rest.dto.sync.PullSyncRequestDto;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.hamcrest.Matchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class PullSyncIntegrationTest extends SyncIntegrationTestBase {

    @Test
    void pullSync_fullSync_returnsAllEntities() throws Exception {
        // Setup: Create test data
        UUID athleteId = UUID.randomUUID();
        TrainingPlanJpaEntity plan1 = createTrainingPlan(athleteId, "Plan 1");
        TrainingPlanJpaEntity plan2 = createTrainingPlan(athleteId, "Plan 2");

        entityManager.persist(plan1);
        entityManager.persist(plan2);
        flushAndClear();

        // Test: Full sync (no lastSyncTime)
        PullSyncRequestDto request = new PullSyncRequestDto(
            List.of("TrainingPlan"),
            null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.totalEntities", is(2)))
            .andExpect(jsonPath("$.syncTimestamp").exists())
            .andExpect(jsonPath("$.entities.TrainingPlan", hasSize(2)))
            .andExpect(jsonPath("$.entities.TrainingPlan[0].name").exists());
    }

    @Test
    void pullSync_incrementalSync_returnsOnlyRecentEntities() throws Exception {
        // Setup: Create old and new plans
        UUID athleteId = UUID.randomUUID();
        LocalDateTime twoHoursAgo = LocalDateTime.now().minusHours(2);
        LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);

        TrainingPlanJpaEntity oldPlan = createTrainingPlan(athleteId, "Old Plan");
        oldPlan.setUpdatedAt(twoHoursAgo);

        TrainingPlanJpaEntity newPlan = createTrainingPlan(athleteId, "New Plan");
        newPlan.setUpdatedAt(LocalDateTime.now());

        entityManager.persist(oldPlan);
        entityManager.persist(newPlan);
        flushAndClear();

        // Test: Incremental sync
        PullSyncRequestDto request = new PullSyncRequestDto(
            List.of("TrainingPlan"),
            oneHourAgo
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.totalEntities", is(1)))
            .andExpect(jsonPath("$.entities.TrainingPlan[0].name", is("New Plan")));
    }

    @Test
    void pullSync_multipleEntityTypes_returnsAll() throws Exception {
        // Setup: Create multiple entity types
        UUID athleteId = UUID.randomUUID();
        TrainingPlanJpaEntity plan = createTrainingPlan(athleteId, "Plan");
        // SetSessionJpaEntity session = createSetSession(athleteId);

        entityManager.persist(plan);
        // entityManager.persist(session);
        flushAndClear();

        // Test: Pull multiple types
        PullSyncRequestDto request = new PullSyncRequestDto(
            List.of("TrainingPlan", "SetSession"),
            null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.entities.TrainingPlan").exists())
            .andExpect(jsonPath("$.entities.SetSession").exists());
    }

    @Test
    void pullSync_noData_returnsEmptyResponse() throws Exception {
        PullSyncRequestDto request = new PullSyncRequestDto(
            List.of("TrainingPlan"),
            null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.totalEntities", is(0)))
            .andExpect(jsonPath("$.entities").isEmpty());
    }

    private TrainingPlanJpaEntity createTrainingPlan(UUID athleteId, String name) {
        TrainingPlanJpaEntity plan = TrainingPlanJpaEntity.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name(name)
            .description("Description")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .status("ACTIVE")
            .build();
        plan.setCreatedAt(LocalDateTime.now());
        plan.setUpdatedAt(LocalDateTime.now());
        return plan;
    }
}
```

### 3. Push Sync Integration Test

**File:** `src/test/java/com/liftlogger/integration/PushSyncIntegrationTest.java`

```java
package com.liftlogger.integration;

import com.liftlogger.infrastructure.rest.dto.TrainingPlanDto;
import com.liftlogger.infrastructure.rest.dto.sync.PushSyncRequestDto;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.hamcrest.Matchers.*;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

class PushSyncIntegrationTest extends SyncIntegrationTestBase {

    @Test
    void pushSync_validEntities_savesSuccessfully() throws Exception {
        UUID athleteId = UUID.randomUUID();

        TrainingPlanDto plan = new TrainingPlanDto(
            UUID.randomUUID(),
            athleteId,
            "Test Plan",
            "Description",
            LocalDate.now(),
            LocalDate.now().plusDays(30),
            "ACTIVE",
            LocalDateTime.now(),
            LocalDateTime.now(),
            athleteId,
            athleteId
        );

        PushSyncRequestDto request = new PushSyncRequestDto(
            Map.of("TrainingPlan", List.of(plan))
        );

        mockMvc.perform(post("/api/v1/sync/push")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.successCount", is(1)))
            .andExpect(jsonPath("$.failureCount", is(0)))
            .andExpect(jsonPath("$.failures", hasSize(0)));

        // Verify entity was saved
        var savedPlan = entityManager.find(
            com.liftlogger.infrastructure.persistence.entity.TrainingPlanJpaEntity.class,
            plan.id()
        );
        assertThat(savedPlan).isNotNull();
        assertThat(savedPlan.getName()).isEqualTo("Test Plan");
    }

    @Test
    void pushSync_invalidEntity_returnsFailures() throws Exception {
        UUID athleteId = UUID.randomUUID();

        // Invalid: end date before start date
        TrainingPlanDto invalidPlan = new TrainingPlanDto(
            UUID.randomUUID(),
            athleteId,
            "Invalid Plan",
            "Description",
            LocalDate.now(),
            LocalDate.now().minusDays(1),  // Invalid
            "ACTIVE",
            LocalDateTime.now(),
            LocalDateTime.now(),
            athleteId,
            athleteId
        );

        PushSyncRequestDto request = new PushSyncRequestDto(
            Map.of("TrainingPlan", List.of(invalidPlan))
        );

        mockMvc.perform(post("/api/v1/sync/push")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.successCount", is(0)))
            .andExpect(jsonPath("$.failureCount", is(1)))
            .andExpect(jsonPath("$.failures[0].entityType", is("TrainingPlan")))
            .andExpect(jsonPath("$.failures[0].errors", not(empty())));
    }

    @Test
    void pushSync_mixedValidation_returnsPartialSuccess() throws Exception {
        UUID athleteId = UUID.randomUUID();

        TrainingPlanDto validPlan = new TrainingPlanDto(
            UUID.randomUUID(),
            athleteId,
            "Valid Plan",
            "Description",
            LocalDate.now(),
            LocalDate.now().plusDays(30),
            "ACTIVE",
            LocalDateTime.now(),
            LocalDateTime.now(),
            athleteId,
            athleteId
        );

        TrainingPlanDto invalidPlan = new TrainingPlanDto(
            UUID.randomUUID(),
            athleteId,
            "",  // Invalid: empty name
            "Description",
            LocalDate.now(),
            LocalDate.now().plusDays(30),
            "ACTIVE",
            LocalDateTime.now(),
            LocalDateTime.now(),
            athleteId,
            athleteId
        );

        PushSyncRequestDto request = new PushSyncRequestDto(
            Map.of("TrainingPlan", List.of(validPlan, invalidPlan))
        );

        mockMvc.perform(post("/api/v1/sync/push")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.successCount", is(1)))
            .andExpect(jsonPath("$.failureCount", is(1)));
    }

    @Test
    void pushSync_batchSave_handlesLargeDataset() throws Exception {
        UUID athleteId = UUID.randomUUID();

        // Create 100 valid plans
        List<TrainingPlanDto> plans = IntStream.range(0, 100)
            .mapToObj(i -> new TrainingPlanDto(
                UUID.randomUUID(),
                athleteId,
                "Plan " + i,
                "Description",
                LocalDate.now().plusDays(i * 10),
                LocalDate.now().plusDays(i * 10 + 9),
                "ACTIVE",
                LocalDateTime.now(),
                LocalDateTime.now(),
                athleteId,
                athleteId
            ))
            .toList();

        PushSyncRequestDto request = new PushSyncRequestDto(
            Map.of("TrainingPlan", plans)
        );

        long startTime = System.currentTimeMillis();

        mockMvc.perform(post("/api/v1/sync/push")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request))
                .with(user("test-user").roles("ATHLETE")))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.successCount", is(100)))
            .andExpect(jsonPath("$.failureCount", is(0)));

        long duration = System.currentTimeMillis() - startTime;
        System.out.println("Batch save of 100 entities took: " + duration + "ms");

        // Performance assertion: Should complete in reasonable time
        assertThat(duration).isLessThan(5000);  // 5 seconds
    }
}
```

### 4. Performance Test

**File:** `src/test/java/com/liftlogger/integration/SyncPerformanceTest.java`

```java
package com.liftlogger.integration;

import org.junit.jupiter.api.Test;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.IntStream;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Performance tests for sync operations
 */
@ActiveProfiles("test")
class SyncPerformanceTest extends SyncIntegrationTestBase {

    @Test
    void pullSync_largeDataset_performsWell() {
        // Setup: Create 1000 training plans
        UUID athleteId = UUID.randomUUID();
        List<TrainingPlanJpaEntity> plans = IntStream.range(0, 1000)
            .mapToObj(i -> createTrainingPlan(athleteId, "Plan " + i))
            .toList();

        plans.forEach(entityManager::persist);
        flushAndClear();

        // Test: Pull all entities
        long startTime = System.currentTimeMillis();

        List<TrainingPlan> pulledPlans = pullSyncService.pullEntities(
            athleteId,
            new PullSyncRequest(List.of("TrainingPlan"), null)
        ).entities().get("TrainingPlan");

        long duration = System.currentTimeMillis() - startTime;

        // Assertions
        assertThat(pulledPlans).hasSize(1000);
        assertThat(duration).isLessThan(2000);  // Should complete in < 2 seconds

        System.out.println("Pull sync of 1000 entities took: " + duration + "ms");
    }

    @Test
    void pushSync_batchProcessing_usesOptimalBatching() {
        // Create 500 entities to test batching behavior
        UUID athleteId = UUID.randomUUID();
        List<TrainingPlan> plans = IntStream.range(0, 500)
            .mapToObj(i -> TrainingPlan.builder()
                .id(UUID.randomUUID())
                .athleteId(athleteId)
                .name("Plan " + i)
                .startDate(LocalDate.now().plusDays(i * 10))
                .endDate(LocalDate.now().plusDays(i * 10 + 9))
                .status("ACTIVE")
                .build())
            .toList();

        long startTime = System.currentTimeMillis();

        PushSyncResponse response = pushSyncService.pushEntities(
            athleteId,
            new PushSyncRequest(Map.of("TrainingPlan", plans))
        );

        long duration = System.currentTimeMillis() - startTime;

        // Assertions
        assertThat(response.successCount()).isEqualTo(500);
        assertThat(duration).isLessThan(3000);  // Should complete in < 3 seconds

        System.out.println("Push sync of 500 entities took: " + duration + "ms");
    }
}
```

### 5. Test Application Properties

**File:** `src/test/resources/application-test.yml`

```yaml
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    driver-class-name: org.h2.Driver
    username: sa
    password:

  jpa:
    hibernate:
      ddl-auto: create-drop
    properties:
      hibernate:
        dialect: org.hibernate.dialect.H2Dialect
        jdbc:
          batch_size: 50
        show_sql: false

  security:
    # Disable security for tests
    enabled: false

logging:
  level:
    com.liftlogger: DEBUG
    org.hibernate.SQL: DEBUG
```

## Acceptance Criteria

- ✅ Integration tests cover full pull sync flow
- ✅ Integration tests cover full push sync flow with validation
- ✅ Tests verify partial failures work correctly
- ✅ Performance tests verify batch processing efficiency
- ✅ Tests verify incremental sync vs full sync
- ✅ Tests verify multi-entity-type sync
- ✅ Tests verify ownership and security rules
- ✅ All tests pass with H2 in-memory database
- ✅ Performance benchmarks documented

## Test Coverage Goals

- Pull sync: 90%+ coverage
- Push sync: 90%+ coverage
- Validators: 95%+ coverage
- Mappers: 90%+ coverage

## Next Step

After completing this step, move to **11-performance-optimization.md** to optimize batch processing and parallel queries.
