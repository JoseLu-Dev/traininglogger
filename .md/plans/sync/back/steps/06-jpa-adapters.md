# Step 6: JPA Adapters

## Objective
Implement the infrastructure layer with JPA repositories that adapt to domain repository ports using JPA Criteria API for generic queries.

## Files to Create

### 1. JPA Entity Base Class

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/entity/BaseJpaEntity.java`

```java
package com.liftlogger.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Base class for all JPA entities with audit fields
 */
@MappedSuperclass
@Getter
@Setter
public abstract class BaseJpaEntity {

    @Id
    @Column(columnDefinition = "BINARY(16)")
    private UUID id;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    @Column(name = "created_by", columnDefinition = "BINARY(16)")
    private UUID createdBy;

    @Column(name = "updated_by", columnDefinition = "BINARY(16)")
    private UUID updatedBy;

    @PrePersist
    protected void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
}
```

### 2. Example JPA Entity

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/entity/TrainingPlanJpaEntity.java`

```java
package com.liftlogger.infrastructure.persistence.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "training_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TrainingPlanJpaEntity extends BaseJpaEntity {

    @Column(name = "athlete_id", nullable = false, columnDefinition = "BINARY(16)")
    private UUID athleteId;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date", nullable = false)
    private LocalDate endDate;

    @Column(nullable = false)
    private String status;

    @Index(name = "idx_athlete_updated", columnList = "athleteId, updatedAt")
}
```

### 3. Generic JPA Repository Adapter

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/adapter/GenericJpaSyncAdapter.java`

```java
package com.liftlogger.infrastructure.persistence.adapter;

import com.liftlogger.domain.repository.GenericSyncRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.*;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Generic JPA adapter that implements sync repository operations using Criteria API.
 * This adapter is extended by entity-specific adapters.
 *
 * @param <D> Domain entity type
 * @param <J> JPA entity type
 */
@RequiredArgsConstructor
public abstract class GenericJpaSyncAdapter<D, J> implements GenericSyncRepository<D> {

    @PersistenceContext
    protected final EntityManager entityManager;

    protected abstract Class<J> getJpaEntityClass();

    protected abstract Class<D> getDomainEntityClass();

    protected abstract String getOwnerFieldName();

    protected abstract D toDomain(J jpaEntity);

    protected abstract J toJpa(D domainEntity);

    protected abstract List<D> toDomainList(List<J> jpaEntities);

    @Override
    public List<D> findByOwnerAndUpdatedAfter(UUID ownerId, LocalDateTime lastSyncTime) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
        Root<J> root = query.from(getJpaEntityClass());

        Predicate ownerPredicate = cb.equal(root.get(getOwnerFieldName()), ownerId);
        Predicate updatedPredicate = cb.greaterThan(root.get("updatedAt"), lastSyncTime);

        query.where(cb.and(ownerPredicate, updatedPredicate));
        query.orderBy(cb.asc(root.get("updatedAt")));

        List<J> results = entityManager.createQuery(query).getResultList();
        return toDomainList(results);
    }

    @Override
    public List<D> findByOwner(UUID ownerId) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
        Root<J> root = query.from(getJpaEntityClass());

        query.where(cb.equal(root.get(getOwnerFieldName()), ownerId));
        query.orderBy(cb.asc(root.get("createdAt")));

        List<J> results = entityManager.createQuery(query).getResultList();
        return toDomainList(results);
    }

    @Override
    public D save(D entity) {
        J jpaEntity = toJpa(entity);
        J savedEntity = entityManager.merge(jpaEntity);
        entityManager.flush();
        return toDomain(savedEntity);
    }

    @Override
    public List<D> saveAll(List<D> entities) {
        List<J> jpaEntities = entities.stream()
            .map(this::toJpa)
            .toList();

        // Batch persist/merge
        for (int i = 0; i < jpaEntities.size(); i++) {
            entityManager.merge(jpaEntities.get(i));

            // Flush and clear every 50 entities for performance
            if (i % 50 == 0) {
                entityManager.flush();
                entityManager.clear();
            }
        }
        entityManager.flush();

        return entities;  // Return original entities (they now have updated timestamps)
    }

    @Override
    public boolean existsById(UUID id) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> query = cb.createQuery(Long.class);
        Root<J> root = query.from(getJpaEntityClass());

        query.select(cb.count(root));
        query.where(cb.equal(root.get("id"), id));

        return entityManager.createQuery(query).getSingleResult() > 0;
    }

    @Override
    public D findById(UUID id) {
        J jpaEntity = entityManager.find(getJpaEntityClass(), id);
        return jpaEntity != null ? toDomain(jpaEntity) : null;
    }
}
```

### 4. Example Entity-Specific Adapter

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/adapter/TrainingPlanJpaAdapter.java`

```java
package com.liftlogger.infrastructure.persistence.adapter;

import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.domain.repository.TrainingPlanRepository;
import com.liftlogger.infrastructure.persistence.entity.TrainingPlanJpaEntity;
import com.liftlogger.infrastructure.persistence.mapper.TrainingPlanMapper;
import jakarta.persistence.EntityManager;
import jakarta.persistence.criteria.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TrainingPlanJpaAdapter extends GenericJpaSyncAdapter<TrainingPlan, TrainingPlanJpaEntity>
    implements TrainingPlanRepository {

    private final EntityManager entityManager;
    private final TrainingPlanMapper mapper;

    @Override
    protected Class<TrainingPlanJpaEntity> getJpaEntityClass() {
        return TrainingPlanJpaEntity.class;
    }

    @Override
    protected Class<TrainingPlan> getDomainEntityClass() {
        return TrainingPlan.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected TrainingPlan toDomain(TrainingPlanJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected TrainingPlanJpaEntity toJpa(TrainingPlan domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<TrainingPlan> toDomainList(List<TrainingPlanJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }

    @Override
    public boolean existsOverlappingPlan(
        UUID athleteId,
        LocalDate startDate,
        LocalDate endDate,
        UUID excludePlanId
    ) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> query = cb.createQuery(Long.class);
        Root<TrainingPlanJpaEntity> root = query.from(TrainingPlanJpaEntity.class);

        // Overlap condition: (start <= endDate) AND (end >= startDate)
        Predicate athletePredicate = cb.equal(root.get("athleteId"), athleteId);
        Predicate startOverlap = cb.lessThanOrEqualTo(root.get("startDate"), endDate);
        Predicate endOverlap = cb.greaterThanOrEqualTo(root.get("endDate"), startDate);
        Predicate notExcluded = cb.notEqual(root.get("id"), excludePlanId);

        query.select(cb.count(root));
        query.where(cb.and(athletePredicate, startOverlap, endOverlap, notExcluded));

        return entityManager.createQuery(query).getSingleResult() > 0;
    }
}
```

### 5. Repository Provider Implementation

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/adapter/RepositoryProviderImpl.java`

```java
package com.liftlogger.infrastructure.persistence.adapter;

import com.liftlogger.application.sync.RepositoryProvider;
import com.liftlogger.domain.repository.GenericSyncRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Spring-based repository provider that looks up repositories from application context
 */
@Component
@RequiredArgsConstructor
public class RepositoryProviderImpl implements RepositoryProvider {

    private final ApplicationContext applicationContext;
    private final Map<Class<?>, GenericSyncRepository<?>> repositoryCache = new ConcurrentHashMap<>();

    @Override
    @SuppressWarnings("unchecked")
    public <T> GenericSyncRepository<T> getRepository(Class<T> entityClass) {
        return (GenericSyncRepository<T>) repositoryCache.computeIfAbsent(
            entityClass,
            this::findRepository
        );
    }

    private GenericSyncRepository<?> findRepository(Class<?> entityClass) {
        // Get all GenericSyncRepository beans
        Map<String, GenericSyncRepository> repositories =
            applicationContext.getBeansOfType(GenericSyncRepository.class);

        // Find the repository that handles this entity class
        for (GenericSyncRepository<?> repository : repositories.values()) {
            if (repository instanceof GenericJpaSyncAdapter<?, ?> adapter) {
                if (adapter.getDomainEntityClass().equals(entityClass)) {
                    return repository;
                }
            }
        }

        throw new IllegalArgumentException(
            "No repository found for entity class: " + entityClass.getName()
        );
    }
}
```

## Database Configuration

**File:** `src/main/resources/application.yml`

```yaml
spring:
  jpa:
    hibernate:
      ddl-auto: validate  # Use Liquibase/Flyway for schema management
    properties:
      hibernate:
        jdbc:
          batch_size: 50  # Batch size for bulk operations
        order_inserts: true
        order_updates: true
        batch_versioned_data: true
    show-sql: false
```

## Testing

**File:** `src/test/java/com/liftlogger/infrastructure/persistence/adapter/TrainingPlanJpaAdapterTest.java`

```java
package com.liftlogger.infrastructure.persistence.adapter;

import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.infrastructure.persistence.entity.TrainingPlanJpaEntity;
import com.liftlogger.infrastructure.persistence.mapper.TrainingPlanMapper;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ActiveProfiles;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@Import({TrainingPlanJpaAdapter.class, TrainingPlanMapper.class})
@ActiveProfiles("test")
class TrainingPlanJpaAdapterTest {

    @Autowired
    private TrainingPlanJpaAdapter adapter;

    @Autowired
    private EntityManager entityManager;

    @Test
    void findByOwner_returnsAllPlansForAthlete() {
        UUID athleteId = UUID.randomUUID();

        // Create test data
        TrainingPlanJpaEntity plan1 = createPlan(athleteId, "Plan 1");
        TrainingPlanJpaEntity plan2 = createPlan(athleteId, "Plan 2");
        TrainingPlanJpaEntity otherPlan = createPlan(UUID.randomUUID(), "Other Plan");

        entityManager.persist(plan1);
        entityManager.persist(plan2);
        entityManager.persist(otherPlan);
        entityManager.flush();

        // Test
        List<TrainingPlan> plans = adapter.findByOwner(athleteId);

        assertThat(plans).hasSize(2);
        assertThat(plans).extracting("athleteId").containsOnly(athleteId);
    }

    @Test
    void findByOwnerAndUpdatedAfter_returnsOnlyRecentPlans() {
        UUID athleteId = UUID.randomUUID();
        LocalDateTime oneHourAgo = LocalDateTime.now().minusHours(1);

        TrainingPlanJpaEntity oldPlan = createPlan(athleteId, "Old Plan");
        oldPlan.setUpdatedAt(LocalDateTime.now().minusDays(1));

        TrainingPlanJpaEntity newPlan = createPlan(athleteId, "New Plan");
        newPlan.setUpdatedAt(LocalDateTime.now());

        entityManager.persist(oldPlan);
        entityManager.persist(newPlan);
        entityManager.flush();

        // Test
        List<TrainingPlan> plans = adapter.findByOwnerAndUpdatedAfter(athleteId, oneHourAgo);

        assertThat(plans).hasSize(1);
        assertThat(plans.get(0).getName()).isEqualTo("New Plan");
    }

    @Test
    void existsOverlappingPlan_detectsOverlap() {
        UUID athleteId = UUID.randomUUID();
        LocalDate start = LocalDate.of(2024, 1, 1);
        LocalDate end = LocalDate.of(2024, 1, 31);

        TrainingPlanJpaEntity existingPlan = createPlan(athleteId, "Existing Plan");
        existingPlan.setStartDate(start);
        existingPlan.setEndDate(end);
        entityManager.persist(existingPlan);
        entityManager.flush();

        // Test overlapping dates
        LocalDate newStart = LocalDate.of(2024, 1, 15);
        LocalDate newEnd = LocalDate.of(2024, 2, 15);

        boolean hasOverlap = adapter.existsOverlappingPlan(
            athleteId,
            newStart,
            newEnd,
            UUID.randomUUID()
        );

        assertThat(hasOverlap).isTrue();
    }

    @Test
    void saveAll_persistsMultipleEntities() {
        UUID athleteId = UUID.randomUUID();
        List<TrainingPlan> plans = List.of(
            createDomainPlan(athleteId, "Plan 1"),
            createDomainPlan(athleteId, "Plan 2"),
            createDomainPlan(athleteId, "Plan 3")
        );

        List<TrainingPlan> saved = adapter.saveAll(plans);

        assertThat(saved).hasSize(3);
        assertThat(adapter.findByOwner(athleteId)).hasSize(3);
    }

    private TrainingPlanJpaEntity createPlan(UUID athleteId, String name) {
        return TrainingPlanJpaEntity.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name(name)
            .description("Description")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .status("ACTIVE")
            .build();
    }

    private TrainingPlan createDomainPlan(UUID athleteId, String name) {
        return TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name(name)
            .description("Description")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .status("ACTIVE")
            .build();
    }
}
```

## Acceptance Criteria

- ✅ `BaseJpaEntity` with audit fields and lifecycle hooks
- ✅ JPA entities for all 12 domain entities
- ✅ `GenericJpaSyncAdapter` with Criteria API queries
- ✅ Entity-specific adapters extending generic adapter
- ✅ `RepositoryProviderImpl` with Spring context lookup
- ✅ Batch size configuration for performance
- ✅ Database indexes on owner and updatedAt fields
- ✅ Tests pass for JPA adapters

## Next Step

After completing this step, move to **07-mapstruct-mappers.md** to implement the mapping layer between domain, JPA, and DTOs.
