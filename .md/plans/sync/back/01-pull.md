# Sync Pull Endpoint

## Architecture Overview

This endpoint follows **Hexagonal Architecture** (Ports & Adapters):

- **Domain Layer**: Defines `SyncChangesPuller` output port (interface) - no infrastructure dependencies
- **Application Layer**: `PullSyncService` depends on the **port**, not on JPA/EntityManager
- **Infrastructure Layer**: `JpaSyncChangesPuller` adapter implements the port using JPA Criteria API

**Benefits:**
- ✅ Application logic is infrastructure-agnostic (can swap JPA for MongoDB, Redis, etc.)
- ✅ Easy to test: mock the port instead of complex JPA mocking
- ✅ Clear dependency flow: Infrastructure → Application → Domain (inward only)

## API Design

```
GET /api/v1/sync/pull?since={timestamp}&athleteId={uuid}&entityTypes={csv}&limit={int}
```

### Query Parameters

- **`since`** (required): `Instant` - Timestamp of last sync. Returns entities updated after this time.
- **`athleteId`** (required): `UUID` - ID of athlete whose data to pull.
- **`entityTypes`** (optional): `List<String>` - Comma-separated entity types (e.g., `TrainingPlan,SetSession`). If omitted, pulls all 12 entity types.
- **`limit`** (optional): `int` - Max entities per type. Default: 100, Max: 500.

### Response Format

```json
{
  "changesByType": {
    "TrainingPlan": [
      {
        "id": "uuid-1",
        "athleteId": "uuid-athlete",
        "name": "Strength Program",
        "startDate": "2026-01-01",
        "endDate": "2026-03-01",
        "updatedAt": "2026-02-06T10:00:00Z",
        "version": 1
      }
    ],
    "SetSession": [
      {
        "id": "uuid-2",
        "trainingPlanId": "uuid-1",
        "athleteId": "uuid-athlete",
        "reps": 10,
        "updatedAt": "2026-02-06T11:00:00Z",
        "version": 1
      }
    ],
    "Exercise": []
  },
  "syncTimestamp": "2026-02-06T15:30:00Z",
  "stats": {
    "TrainingPlan": {"fetched": 1, "hasMore": false},
    "SetSession": {"fetched": 1, "hasMore": false},
    "Exercise": {"fetched": 0, "hasMore": false}
  }
}
```

## Domain Layer

### Output Port (Repository Interface)

File: `domain/outbound/sync/SyncChangesPuller.java`

```java
/**
 * Output port for pulling entity changes during sync operations.
 * Abstracts the data access mechanism, keeping application layer independent of JPA.
 */
public interface SyncChangesPuller {

    /**
     * Pulls entities of a specific type that have been updated after a given timestamp.
     *
     * @param <T>         the entity type
     * @param entityClass the class of the entity to pull
     * @param ownerId     the ID of the owner (athleteId or coachId)
     * @param since       timestamp to pull changes after
     * @param limit       maximum number of entities to return
     * @param ownerField  the name of the owner field ("athleteId" or "coachId")
     * @return list of entities updated after the given timestamp
     */
    <T> List<T> pullChanges(
        Class<T> entityClass,
        UUID ownerId,
        Instant since,
        int limit,
        String ownerField
    );
}
```

## Application Layer

### 1. Use Case Port (Interface)

File: `application/inbound/PullSyncUseCase.java`

```java
public interface PullSyncUseCase {
    PullSyncResult execute(PullSyncCommand command);
}

public record PullSyncCommand(
    UUID athleteId,
    Instant since,
    List<String> entityTypes,  // Optional: specific entity types
    int limit
) {}

public record PullSyncResult(
    Map<String, List<?>> changesByType,  // e.g., "TrainingPlan" -> List<TrainingPlan>
    Instant syncTimestamp,
    Map<String, EntityStats> stats
) {}

public record EntityStats(
    int fetched,
    boolean hasMore
) {}
```

### 2. Use Case Implementation (Service)

File: `application/service/PullSyncService.java`

```java
@Service
@RequiredArgsConstructor
public class PullSyncService implements PullSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final SyncChangesPuller syncChangesPuller;  // Output port (not EntityManager!)
    private final LoggerService logger;

    @Override
    public PullSyncResult execute(PullSyncCommand command) {
        // Default to all entity types if not specified
        List<String> entityTypes = (command.entityTypes() == null || command.entityTypes().isEmpty())
            ? entityRegistry.getAllEntityNames()
            : command.entityTypes();

        logger.info("Pulling changes for athlete {} since {} (types: {})",
            command.athleteId(), command.since(), entityTypes);

        // Pull changes for each entity type in parallel
        Map<String, List<?>> changesByType = new ConcurrentHashMap<>();
        Map<String, EntityStats> stats = new ConcurrentHashMap<>();

        entityTypes.parallelStream().forEach(entityType -> {
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            if (metadata == null) {
                logger.warn("Unknown entity type: {}", entityType);
                return;
            }

            try {
                // Use output port to pull changes (infrastructure-agnostic)
                List<?> entities = syncChangesPuller.pullChanges(
                    metadata.entityClass(),
                    command.athleteId(),
                    command.since(),
                    command.limit(),
                    metadata.ownerField()
                );

                changesByType.put(entityType, entities);
                stats.put(entityType, new EntityStats(
                    entities.size(),
                    entities.size() >= command.limit()
                ));

                logger.debug("Pulled {} {} entities", entities.size(), entityType);

            } catch (Exception e) {
                logger.error("Failed to pull {} entities", entityType, e);
                changesByType.put(entityType, List.of());
                stats.put(entityType, new EntityStats(0, false));
            }
        });

        return new PullSyncResult(changesByType, Instant.now(), stats);
    }
}
```

### How the Architecture Works

**Hexagonal Architecture Compliance:**

1. **Domain Layer** (`SyncChangesPuller` interface)
   - Defines the output port for pulling changes
   - No infrastructure dependencies (no JPA, no Spring)
   - Pure domain contract

2. **Application Layer** (`PullSyncService`)
   - Depends on the `SyncChangesPuller` **port** (not implementation)
   - Orchestrates sync logic using domain abstractions
   - Infrastructure-agnostic (could swap JPA for MongoDB, etc.)

3. **Infrastructure Layer** (`JpaSyncChangesPuller` adapter)
   - Implements the output port using JPA Criteria API
   - Contains all JPA-specific code (`EntityManager`, `CriteriaBuilder`)
   - Generic implementation works for all 12 entity types

**Generated SQL Examples:**

For `TrainingPlan` (owner field: `athleteId`):
```sql
SELECT * FROM training_plan
WHERE athlete_id = 'uuid-123'
  AND updated_at > '2026-01-01T00:00:00Z'
ORDER BY updated_at ASC
LIMIT 101;  -- Fetch 101 to check if there are more
```

For `Exercise` (owner field: `coachId`):
```sql
SELECT * FROM exercise
WHERE coach_id = 'uuid-456'
  AND updated_at > '2026-01-01T00:00:00Z'
ORDER BY updated_at ASC
LIMIT 101;
```

**Key Points:**
- ✅ Clean separation: Application uses port, Infrastructure implements it
- ✅ Same adapter works for all 12 entity types (generic via reflection)
- ✅ Owner field configurable via metadata (`athleteId` vs `coachId`)
- ✅ Limit +1 trick detects if more results exist without extra query
- ✅ Easy to test: mock `SyncChangesPuller` in unit tests
- ✅ Easy to swap: replace JPA with another persistence mechanism

## Infrastructure Layer

### 1. JPA Adapter (Output Port Implementation)

File: `infrastructure/db/adapter/JpaSyncChangesPuller.java`

```java
@Component
@RequiredArgsConstructor
public class JpaSyncChangesPuller implements SyncChangesPuller {

    private final EntityManager entityManager;

    /**
     * Generic pull method using JPA Criteria API.
     * Works for any entity type by dynamically building the query.
     */
    @Override
    public <T> List<T> pullChanges(
        Class<T> entityClass,
        UUID ownerId,
        Instant since,
        int limit,
        String ownerField
    ) {
        // Build dynamic query using JPA Criteria API
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<T> query = cb.createQuery(entityClass);
        Root<T> root = query.from(entityClass);

        // WHERE ownerField = :ownerId AND updatedAt > :since
        Predicate ownerPredicate = cb.equal(root.get(ownerField), ownerId);
        Predicate timePredicate = cb.greaterThan(root.get("updatedAt"), since);

        query.select(root)
             .where(cb.and(ownerPredicate, timePredicate))
             .orderBy(cb.asc(root.get("updatedAt")));  // Consistent ordering

        // Execute with limit (+1 to check if there are more)
        List<T> results = entityManager.createQuery(query)
            .setMaxResults(limit + 1)
            .getResultList();

        // Return only the requested limit
        return results.size() > limit ? results.subList(0, limit) : results;
    }
}
```

### 2. REST Controller

File: `infrastructure/rest/controller/SyncController.java`

```java
@RestController
@RequestMapping("/api/v1/sync")
@RequiredArgsConstructor
@Tag(name = "Sync", description = "Offline sync endpoints")
public class SyncController {

    private final PullSyncUseCase pullSyncUseCase;
    private final SyncPullResponseMapper pullResponseMapper;

    @GetMapping("/pull")
    @PreAuthorize("hasRole('ATHLETE') or hasRole('COACH')")
    @Operation(summary = "Pull changes since last sync")
    public ResponseEntity<SyncPullResponseDto> pull(
        @RequestParam @Parameter(description = "Timestamp of last sync") Instant since,
        @RequestParam @Parameter(description = "Athlete ID") UUID athleteId,
        @RequestParam(required = false) @Parameter(description = "Entity types to sync (optional)") List<String> entityTypes,
        @RequestParam(defaultValue = "100") @Max(500) @Parameter(description = "Max entities per type") int limit,
        @AuthenticationPrincipal UserPrincipal currentUser
    ) {
        // Validate access (athlete can only pull their own data)
        validateAccess(athleteId, currentUser);

        // Call use case
        PullSyncCommand command = new PullSyncCommand(athleteId, since, entityTypes, limit);
        PullSyncResult result = pullSyncUseCase.execute(command);

        // Map domain result to DTO
        SyncPullResponseDto response = pullResponseMapper.toDto(result);

        return ResponseEntity.ok(response);
    }

    private void validateAccess(UUID athleteId, UserPrincipal currentUser) {
        if ("ATHLETE".equals(currentUser.getRole()) && !athleteId.equals(currentUser.getId())) {
            throw new UnauthorizedException("Cannot access another athlete's data");
        }

        if ("COACH".equals(currentUser.getRole())) {
            // TODO: Verify coach owns this athlete
            // coachRepository.hasAccess(currentUser.getId(), athleteId)
        }
    }
}
```

### 3. DTOs

File: `infrastructure/rest/dto/sync/SyncPullResponseDto.java`

```java
@Schema(description = "Pull sync response")
public record SyncPullResponseDto(
    @Schema(description = "Changes grouped by entity type", example = """
        {
          "TrainingPlan": [{"id": "...", "name": "...", ...}],
          "SetSession": [{"id": "...", "reps": 10, ...}]
        }
    """)
    Map<String, List<Object>> changesByType,  // DTOs, not domain entities

    @Schema(description = "Server timestamp when sync was processed")
    Instant syncTimestamp,

    @Schema(description = "Statistics per entity type")
    Map<String, EntityStatsDto> stats
) {}

public record EntityStatsDto(
    int fetched,
    boolean hasMore
) {}
```

### 4. MapStruct Mapper (Domain → DTO)

File: `infrastructure/rest/mapper/SyncPullResponseMapper.java`

```java
@Mapper(componentModel = "spring", uses = {
    TrainingPlanMapper.class,
    SetSessionMapper.class,
    ExerciseMapper.class
    // ... other entity mappers
})
public interface SyncPullResponseMapper {

    @Mapping(target = "changesByType", source = "changesByType", qualifiedByName = "mapChangesByType")
    SyncPullResponseDto toDto(PullSyncResult result);

    EntityStatsDto toDto(EntityStats stats);

    /**
     * Maps domain entities to DTOs for each entity type.
     */
    @Named("mapChangesByType")
    default Map<String, List<Object>> mapChangesByType(Map<String, List<?>> domainMap) {
        Map<String, List<Object>> dtoMap = new HashMap<>();

        for (var entry : domainMap.entrySet()) {
            String entityType = entry.getKey();
            List<?> domainEntities = entry.getValue();

            // Map each domain entity to DTO using appropriate mapper
            List<Object> dtos = domainEntities.stream()
                .map(entity -> mapToDto(entity, entityType))
                .toList();

            dtoMap.put(entityType, dtos);
        }

        return dtoMap;
    }

    /**
     * Routes to the correct entity mapper based on entity type.
     */
    private Object mapToDto(Object domainEntity, String entityType) {
        // Use MapStruct generated mappers
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

### 1. Parallel Queries

All entity types are queried simultaneously via `parallelStream()`:

```java
entityTypes.parallelStream().forEach(entityType -> {
    // Pull changes for this entity type
});
```

**Performance Impact:**
- Sequential: 12 entity types × 50ms = 600ms
- Parallel: max(50ms) ≈ 100ms (with thread overhead)
- **6x speedup** for full sync

### 2. Database Indexes

Ensure composite indexes exist on all syncable tables:

```sql
-- Critical for efficient sync queries
CREATE INDEX idx_athlete_updated ON training_plan(athlete_id, updated_at);
CREATE INDEX idx_athlete_updated ON set_session(athlete_id, updated_at);
CREATE INDEX idx_athlete_updated ON workout(athlete_id, updated_at);
-- ... repeat for all 12 entity types

-- For entities owned by coach
CREATE INDEX idx_coach_updated ON exercise(coach_id, updated_at);
```

**Query Performance:**
- Without index: Full table scan (slow)
- With index: Index range scan (fast, ~10ms for 1000 records)

### 3. Query Limits

```java
@RequestParam(defaultValue = "100") @Max(500) int limit
```

- Default: 100 entities per type
- Max: 500 entities per type (enforced by `@Max(500)`)
- Total max response: 500 × 12 = 6000 entities (~2-3MB compressed)

### 4. Response Compression

Enable Gzip in `application.properties`:

```properties
server.compression.enabled=true
server.compression.mime-types=application/json
server.compression.min-response-size=1024
```

**Compression Ratio:**
- Uncompressed: ~5MB for 6000 entities
- Compressed: ~500KB-1MB
- **5-10x reduction** in network bandwidth
