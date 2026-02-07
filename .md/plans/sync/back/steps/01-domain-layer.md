# Step 1: Domain Layer

## Objective
Create pure domain entities and repository interfaces (ports) with zero framework dependencies.

## Files to Create

### 1. Domain Exceptions

**File:** `src/main/java/com/liftlogger/domain/exception/DomainException.java`

```java
package com.liftlogger.domain.exception;

public class DomainException extends RuntimeException {
    public DomainException(String message) {
        super(message);
    }

    public DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}
```

**File:** `src/main/java/com/liftlogger/domain/exception/EntityNotFoundException.java`

```java
package com.liftlogger.domain.exception;

import java.util.UUID;

public class EntityNotFoundException extends DomainException {
    public EntityNotFoundException(String entityType, UUID id) {
        super(String.format("%s with id %s not found", entityType, id));
    }
}
```

**File:** `src/main/java/com/liftlogger/domain/exception/ValidationException.java`

```java
package com.liftlogger.domain.exception;

import java.util.List;

public class ValidationException extends DomainException {
    private final List<String> errors;

    public ValidationException(List<String> errors) {
        super("Validation failed: " + String.join(", ", errors));
        this.errors = errors;
    }

    public List<String> getErrors() {
        return errors;
    }
}
```

### 2. Repository Ports (Interfaces)

**File:** `src/main/java/com/liftlogger/domain/repository/GenericSyncRepository.java`

```java
package com.liftlogger.domain.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Generic repository interface for sync operations.
 * All entity-specific repositories extend this.
 */
public interface GenericSyncRepository<T> {

    /**
     * Find entities owned by user, updated after lastSyncTime
     */
    List<T> findByOwnerAndUpdatedAfter(UUID ownerId, LocalDateTime lastSyncTime);

    /**
     * Find entities owned by user, all records
     */
    List<T> findByOwner(UUID ownerId);

    /**
     * Save entity (create or update)
     */
    T save(T entity);

    /**
     * Save multiple entities in batch
     */
    List<T> saveAll(List<T> entities);

    /**
     * Check if entity exists by ID
     */
    boolean existsById(UUID id);

    /**
     * Find entity by ID
     */
    T findById(UUID id);
}
```

**File:** `src/main/java/com/liftlogger/domain/repository/TrainingPlanRepository.java`

```java
package com.liftlogger.domain.repository;

import com.liftlogger.domain.entity.TrainingPlan;
import java.time.LocalDate;
import java.util.UUID;

public interface TrainingPlanRepository extends GenericSyncRepository<TrainingPlan> {

    /**
     * Check if there's an overlapping training plan for the athlete
     */
    boolean existsOverlappingPlan(
        UUID athleteId,
        LocalDate startDate,
        LocalDate endDate,
        UUID excludePlanId
    );
}
```

### 3. Domain Entities (Example)

**File:** `src/main/java/com/liftlogger/domain/entity/TrainingPlan.java`

```java
package com.liftlogger.domain.entity;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Pure domain entity - no JPA annotations
 */
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TrainingPlan {

    private UUID id;
    private UUID athleteId;  // Owner field
    private String name;
    private String description;
    private LocalDate startDate;
    private LocalDate endDate;
    private String status;  // DRAFT, ACTIVE, COMPLETED

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UUID createdBy;
    private UUID updatedBy;
}
```

**File:** `src/main/java/com/liftlogger/domain/entity/SetSession.java`

```java
package com.liftlogger.domain.entity;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SetSession {

    private UUID id;
    private UUID athleteId;  // Owner field
    private UUID trainingPlanId;
    private UUID exerciseId;
    private LocalDateTime sessionDate;
    private Integer reps;
    private Double weight;
    private String notes;

    // Audit fields
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private UUID createdBy;
    private UUID updatedBy;
}
```

## Repository Interfaces to Create

Create similar repository interfaces for all 10 entities:

1. ✅ `TrainingPlanRepository`
2. `SetSessionRepository`
3. `ExerciseRepository`
4. `UserRepository`  // For both coaches and athletes
5. `VariantRepository`
6. `ExercisePlanRepository`
7. `SetPlanRepository`
8. `TrainingSessionRepository`
9. `ExerciseSessionRepository`
10. `BodyWeightEntryRepository`

## Acceptance Criteria

- ✅ All domain entities are POJOs with Lombok annotations
- ✅ No framework dependencies (no JPA, no Spring annotations)
- ✅ Repository interfaces define ports (contracts)
- ✅ Domain exceptions are clear and specific
- ✅ All entities have audit fields (createdAt, updatedAt, createdBy, updatedBy)
- ✅ All entities have owner field (athleteId or coachId)

## Next Step

After completing this step, move to **02-validation-framework.md** to create the validation interfaces.
