# Sync Push Endpoint

## API Design

```
POST /api/v1/sync/push
```

### Request Format (Frontend-Grouped)

Frontend groups entities by type before sending:

```json
{
  "TrainingPlan": [
    {
      "id": "uuid-1",
      "athleteId": "uuid-athlete",
      "name": "Updated Strength Program",
      "startDate": "2026-01-01",
      "endDate": "2026-03-01",
      "version": 1
    },
    {
      "id": "uuid-2",
      "athleteId": "uuid-athlete",
      "name": "Invalid Program",
      "startDate": "2026-03-01",
      "endDate": "2026-01-01",
      "version": 1
    }
  ],
  "SetSession": [
    {
      "id": "uuid-3",
      "trainingPlanId": "uuid-1",
      "athleteId": "uuid-athlete",
      "reps": 10,
      "version": 1
    }
  ]
}
```

**Why Frontend Grouping?**

- ✅ No server-side re-grouping overhead
- ✅ Cleaner API contract
- ✅ Frontend controls batch size per entity type
- ✅ More efficient JSON structure

### Response Format (Partial Failures)

Server validates each entity and returns successes/failures:

```json
{
  "succeeded": [
    {
      "entityType": "TrainingPlan",
      "entityId": "uuid-1",
      "entity": {
        "id": "uuid-1",
        "name": "Updated Strength Program",
        "updatedAt": "2026-02-06T15:30:00Z",
        "version": 2
      }
    },
    {
      "entityType": "SetSession",
      "entityId": "uuid-3",
      "entity": {
        "id": "uuid-3",
        "updatedAt": "2026-02-06T15:30:00Z",
        "version": 2
      }
    }
  ],
  "failed": [
    {
      "entityType": "TrainingPlan",
      "entityId": "uuid-2",
      "errors": [
        {
          "field": "endDate",
          "code": "INVALID_RANGE",
          "message": "End date must be after start date"
        }
      ]
    }
  ],
  "summary": {
    "totalReceived": 3,
    "succeeded": 2,
    "failed": 1
  }
}
```

**Why Partial Failures?**

- ✅ Better UX: User sees what synced successfully
- ✅ Don't lose valid data due to one bad entity
- ✅ Offline-first: Device can retry failed entities later
- ✅ Detailed errors show exactly what went wrong

## Domain Layer

### Outbound Port (Repository Interface)

File: `domain/outbound/repository/BatchEntityRepository.java`

```java
/**
 * Port for batch entity persistence operations.
 * Abstracts away JPA-specific batching logic from the application layer.
 */
public interface BatchEntityRepository {

    /**
     * Saves a batch of entities of the same type.
     * Uses optimized batch operations for performance.
     *
     * @param entities List of domain entities to save
     * @param <T> The entity type
     * @return List of saved entities with updated metadata
     */
    <T> List<T> saveBatch(List<T> entities);
}
```

## Application Layer

### 1. Use Case Port (Interface)

File: `application/inbound/PushSyncUseCase.java`

```java
public interface PushSyncUseCase {
    PushSyncResult execute(PushSyncCommand command);
}

public record PushSyncCommand(
    UUID currentUserId,
    String currentUserRole,
    Map<String, List<?>> changesByType  // e.g., "TrainingPlan" -> List<TrainingPlan>
) {}

public record PushSyncResult(
    List<SyncSuccess> succeeded,
    List<SyncFailure> failed,
    SyncSummary summary
) {}

public record SyncSuccess(
    String entityType,
    UUID entityId,
    Object entity  // The saved entity with updated version/timestamp
) {}

public record SyncFailure(
    String entityType,
    UUID entityId,
    List<ValidationError> errors
) {}

public record SyncSummary(
    int totalReceived,
    int succeeded,
    int failed
) {}
```

### 2. Use Case Implementation (Service)

File: `application/service/PushSyncService.java`

```java
@Service
@RequiredArgsConstructor
public class PushSyncService implements PushSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final BatchEntityRepository batchEntityRepository;
    private final LoggerService logger;

    @Override
    @Transactional
    public PushSyncResult execute(PushSyncCommand command) {
        logger.info("Pushing changes for user {} (role: {}, types: {})",
            command.currentUserId(), command.currentUserRole(), command.changesByType().keySet());

        List<SyncSuccess> successes = new ArrayList<>();
        List<SyncFailure> failures = new ArrayList<>();

        ValidationContext validationContext = new ValidationContext(
            command.currentUserId(),
            command.currentUserRole()
        );

        // Process each entity type
        for (var entry : command.changesByType().entrySet()) {
            String entityType = entry.getKey();
            List<?> entitiesRaw = entry.getValue();

            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            if (metadata == null) {
                logger.warn("Unknown entity type: {}", entityType);
                continue;
            }

            // Process batch for this entity type
            processBatch(
                metadata,
                entitiesRaw,
                command.currentUserId(),
                validationContext,
                successes,
                failures
            );
        }

        int total = successes.size() + failures.size();
        logger.info("Push completed: {} succeeded, {} failed", successes.size(), failures.size());

        return new PushSyncResult(
            successes,
            failures,
            new SyncSummary(total, successes.size(), failures.size())
        );
    }

    /**
     * Process a batch of entities of the same type.
     * Validates each entity and saves only the valid ones.
     * Returns partial failures for invalid entities.
     */
    private <T> void processBatch(
        EntityMetadata<T> metadata,
        List<?> entitiesRaw,
        UUID currentUserId,
        ValidationContext validationContext,
        List<SyncSuccess> successes,
        List<SyncFailure> failures
    ) {
        List<T> entities = (List<T>) entitiesRaw;  // Cast to typed list

        Instant now = Instant.now();
        List<T> validEntities = new ArrayList<>();

        for (T entity : entities) {
            UUID entityId = extractId(entity);

            try {
                // 1. Validate ownership (authorization)
                UUID ownerId = extractOwnerId(entity, metadata.ownerField());
                if (!ownerId.equals(currentUserId)) {
                    failures.add(new SyncFailure(
                        metadata.entityName(),
                        entityId,
                        List.of(new ValidationError("ownership", "UNAUTHORIZED",
                            "Cannot sync entity owned by another user"))
                    ));
                    continue;
                }

                // 2. Validate business rules
                ValidationResult result = metadata.validator().validate(entity, validationContext);
                if (!result.isValid()) {
                    failures.add(new SyncFailure(
                        metadata.entityName(),
                        entityId,
                        result.errors()
                    ));
                    continue;
                }

                // 3. Update timestamps and version (same timestamp for entire batch)
                setUpdatedAt(entity, now);
                incrementVersion(entity);

                // 4. Collect valid entities for batch save
                validEntities.add(entity);

            } catch (Exception e) {
                logger.error("Failed to validate entity {}", entityId, e);
                failures.add(new SyncFailure(
                    metadata.entityName(),
                    entityId,
                    List.of(new ValidationError("system", "INTERNAL_ERROR", e.getMessage()))
                ));
            }
        }

        // 5. Save all valid entities in a single batch (via port)
        if (!validEntities.isEmpty()) {
            try {
                List<T> savedEntities = batchEntityRepository.saveBatch(validEntities);

                // Add successes
                for (T savedEntity : savedEntities) {
                    successes.add(new SyncSuccess(
                        metadata.entityName(),
                        extractId(savedEntity),
                        savedEntity
                    ));
                }
            } catch (Exception e) {
                logger.error("Batch save failed for entity type {}", metadata.entityName(), e);

                // If batch fails, mark all as failed
                for (T entity : validEntities) {
                    failures.add(new SyncFailure(
                        metadata.entityName(),
                        extractId(entity),
                        List.of(new ValidationError("system", "BATCH_SAVE_FAILED", e.getMessage()))
                    ));
                }
            }
        }
    }

    // Reflection helpers for generic entity access

    private UUID extractId(Object entity) {
        try {
            return (UUID) entity.getClass().getMethod("getId").invoke(entity);
        } catch (Exception e) {
            throw new IllegalStateException("Entity must have getId() method", e);
        }
    }

    private UUID extractOwnerId(Object entity, String ownerField) {
        try {
            String getter = "get" + Character.toUpperCase(ownerField.charAt(0)) + ownerField.substring(1);
            return (UUID) entity.getClass().getMethod(getter).invoke(entity);
        } catch (Exception e) {
            throw new IllegalStateException("Entity must have " + ownerField + " field", e);
        }
    }

    private void setUpdatedAt(Object entity, Instant updatedAt) {
        try {
            entity.getClass().getMethod("setUpdatedAt", Instant.class).invoke(entity, updatedAt);
        } catch (Exception e) {
            throw new IllegalStateException("Entity must have setUpdatedAt() method", e);
        }
    }

    private void incrementVersion(Object entity) {
        try {
            Integer currentVersion = (Integer) entity.getClass().getMethod("getVersion").invoke(entity);
            entity.getClass().getMethod("setVersion", Integer.class).invoke(entity, currentVersion + 1);
        } catch (Exception e) {
            throw new IllegalStateException("Entity must have version field", e);
        }
    }
}
```

### Validation Flow

```
For each entity in batch:
  ┌─────────────────────────────┐
  │ 1. Validate Ownership        │ → UNAUTHORIZED if owner ≠ currentUser
  │    (athleteId == currentUserId)│
  └──────────┬──────────────────┘
             │ ✓
  ┌──────────▼──────────────────┐
  │ 2. Validate Business Rules   │ → FAILED if validation errors
  │    (validator.validate())    │
  └──────────┬──────────────────┘
             │ ✓
  ┌──────────▼──────────────────┐
  │ 3. Update Metadata           │
  │    - version++               │
  │    - updatedAt = now         │
  └──────────┬──────────────────┘
             │
  ┌──────────▼──────────────────┐
  │ 4. Collect valid entities    │
  └──────────┬──────────────────┘
             │
After validation completes:
  ┌──────────▼──────────────────┐
  │ 5. Save batch via port       │ → SUCCESS (entire batch)
  │    repository.saveBatch()    │ → BATCH_SAVE_FAILED (on error)
  └─────────────────────────────┘
```

## Infrastructure Layer

### 1. Batch Entity Repository Adapter

File: `infrastructure/db/adapter/BatchEntityJpaAdapter.java`

```java
@Repository
@RequiredArgsConstructor
public class BatchEntityJpaAdapter implements BatchEntityRepository {

    private final EntityManager entityManager;
    private final LoggerService logger;

    @Override
    public <T> List<T> saveBatch(List<T> entities) {
        if (entities.isEmpty()) {
            return Collections.emptyList();
        }

        logger.debug("Saving batch of {} entities", entities.size());

        List<T> savedEntities = new ArrayList<>();

        for (T entity : entities) {
            // Merge each entity (insert or update)
            T savedEntity = entityManager.merge(entity);
            savedEntities.add(savedEntity);
        }

        // Flush to execute batch in a single DB round-trip
        // Hibernate batching configuration (jdbc.batch_size=50) handles this
        entityManager.flush();

        logger.debug("Batch save completed for {} entities", savedEntities.size());

        return savedEntities;
    }
}
```

**Key Points:**

- ✅ Implements the domain port `BatchEntityRepository`
- ✅ Encapsulates JPA/Hibernate concerns (EntityManager)
- ✅ Application layer has zero knowledge of JPA
- ✅ Leverages Hibernate batch configuration for performance

### 2. REST Controller

File: `infrastructure/rest/controller/SyncController.java`

```java
@RestController
@RequestMapping("/api/v1/sync")
@RequiredArgsConstructor
@Tag(name = "Sync", description = "Offline sync endpoints")
public class SyncController {

    private final PushSyncUseCase pushSyncUseCase;
    private final SyncPushRequestMapper pushRequestMapper;
    private final SyncPushResponseMapper pushResponseMapper;

    @PostMapping("/push")
    @PreAuthorize("hasRole('ATHLETE') or hasRole('COACH')")
    @Operation(summary = "Push local changes to server")
    public ResponseEntity<SyncPushResponseDto> push(
        @RequestBody SyncPushRequestDto request,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        // Map DTO to domain command (deserializes JSON to domain entities)
        PushSyncCommand command = pushRequestMapper.toCommand(
            request,
            currentUser.getId(),
            currentUser.getRole()
        );

        // Call use case
        PushSyncResult result = pushSyncUseCase.execute(command);

        // Map domain result to DTO
        SyncPushResponseDto response = pushResponseMapper.toDto(result);

        return ResponseEntity.ok(response);
    }
}
```

### 3. DTOs

File: `infrastructure/rest/dto/sync/SyncPushRequestDto.java`

```java
@Schema(description = "Push sync request (frontend-grouped)")
public record SyncPushRequestDto(
    @Schema(description = "Changes grouped by entity type", example = """
        {
          "TrainingPlan": [{"id": "...", "name": "...", ...}],
          "SetSession": [{"id": "...", "reps": 10, ...}]
        }
    """)
    Map<String, List<Map<String, Object>>> changesByType  // Raw JSON per entity type
) {}
```

File: `infrastructure/rest/dto/sync/SyncPushResponseDto.java`

```java
@Schema(description = "Push sync response (partial failures)")
public record SyncPushResponseDto(
    @Schema(description = "Successfully synced entities")
    List<SyncSuccessDto> succeeded,

    @Schema(description = "Failed entities with validation errors")
    List<SyncFailureDto> failed,

    @Schema(description = "Summary statistics")
    SyncSummaryDto summary
) {}

public record SyncSuccessDto(
    String entityType,
    UUID entityId,
    Object entity  // DTO of the saved entity
) {}

public record SyncFailureDto(
    String entityType,
    UUID entityId,
    List<ValidationErrorDto> errors
) {}

public record ValidationErrorDto(
    String field,
    String code,
    String message
) {}

public record SyncSummaryDto(
    int totalReceived,
    int succeeded,
    int failed
) {}
```

### 4. MapStruct Mappers

File: `infrastructure/rest/mapper/SyncPushRequestMapper.java`

```java
@Mapper(componentModel = "spring")
public interface SyncPushRequestMapper {

    @Autowired
    private EntityRegistry entityRegistry;

    @Autowired
    private ObjectMapper objectMapper;

    /**
     * Deserializes JSON request to domain entities grouped by type.
     */
    default PushSyncCommand toCommand(
        SyncPushRequestDto request,
        UUID currentUserId,
        String currentUserRole
    ) {
        Map<String, List<?>> domainMap = new HashMap<>();

        for (var entry : request.changesByType().entrySet()) {
            String entityType = entry.getKey();
            List<Map<String, Object>> jsonEntities = entry.getValue();

            // Get entity metadata
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            if (metadata == null) {
                continue;  // Unknown entity type, will be logged by service
            }

            // Deserialize JSON to domain entities
            List<?> domainEntities = jsonEntities.stream()
                .map(json -> deserializeToDomain(json, metadata.entityClass()))
                .toList();

            domainMap.put(entityType, domainEntities);
        }

        return new PushSyncCommand(currentUserId, currentUserRole, domainMap);
    }

    private <T> T deserializeToDomain(Map<String, Object> json, Class<T> entityClass) {
        // Use Jackson to deserialize JSON to domain entity
        return objectMapper.convertValue(json, entityClass);
    }
}
```

File: `infrastructure/rest/mapper/SyncPushResponseMapper.java`

```java
@Mapper(componentModel = "spring", uses = {
    TrainingPlanMapper.class,
    SetSessionMapper.class,
    ExerciseMapper.class
    // ... other entity mappers
})
public interface SyncPushResponseMapper {

    @Mapping(target = "succeeded", source = "succeeded")
    @Mapping(target = "failed", source = "failed")
    SyncPushResponseDto toDto(PushSyncResult result);

    @Mapping(target = "entity", source = "entity", qualifiedByName = "mapEntityToDto")
    SyncSuccessDto toDto(SyncSuccess success);

    SyncFailureDto toDto(SyncFailure failure);

    SyncSummaryDto toDto(SyncSummary summary);

    ValidationErrorDto toDto(ValidationError error);

    /**
     * Maps domain entity to DTO based on entity type.
     */
    @Named("mapEntityToDto")
    default Object mapEntityToDto(Object domainEntity, @Context String entityType) {
        return switch (entityType) {
            case "TrainingPlan" -> trainingPlanMapper.toDto((TrainingPlan) domainEntity);
            case "SetSession" -> setSessionMapper.toDto((SetSession) domainEntity);
            case "Exercise" -> exerciseMapper.toDto((Exercise) domainEntity);
            // ... other entity types
            default -> throw new IllegalArgumentException("Unknown entity type: " + entityType);
        };
    }

    // Injected by MapStruct via @uses
    @Autowired
    TrainingPlanMapper trainingPlanMapper;

    @Autowired
    SetSessionMapper setSessionMapper;

    @Autowired
    ExerciseMapper exerciseMapper;
}
```

## Performance Optimizations

### 1. Hibernate Batch Configuration (CRITICAL)

File: `application.properties`

```properties
# Enable JDBC batch inserts/updates (critical for performance)
spring.jpa.properties.hibernate.jdbc.batch_size=50
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true
spring.jpa.properties.hibernate.batch_versioned_data=true
```

**Performance Impact:**

**Without batching:**

```
User pushes 100 entities (50 TrainingPlan, 50 SetSession)
  → 100 individual DB round-trips
  → ~5 seconds on cloud DB
```

**With batching:**

```
User pushes 100 entities (50 TrainingPlan, 50 SetSession)
  → Grouped by entity type: 2 batches
  → entityManager.flush() per entity type
  → 2 DB round-trips (~50ms each)
  → ~0.1 seconds
```

**50x speedup** for typical sync scenarios!

### 2. Single Timestamp Per Batch

All entities in a batch get the same `updatedAt`:

```java
Instant now = Instant.now();  // Once per entity type batch

for (T entity : entities) {
    setUpdatedAt(entity, now);  // Same timestamp
}
```

**Benefits:**

- ✅ Consistent timestamp for pull sync
- ✅ Easier to reason about sync state
- ✅ Reduced System.currentTimeMillis() calls

### 3. Early Validation Failures

Validation failures don't hit the database:

```java
// 1. Ownership check (in-memory)
if (!ownerId.equals(currentUserId)) {
    failures.add(...);
    continue;  // Skip to next entity
}

// 2. Business rules (may query DB)
ValidationResult result = validator.validate(entity, ctx);
if (!result.isValid()) {
    failures.add(...);
    continue;  // Skip to next entity
}

// 3. Collect valid entities
validEntities.add(entity);

// 4. After validation loop: batch save via port
repository.saveBatch(validEntities);  // Only valid entities reach DB
```
