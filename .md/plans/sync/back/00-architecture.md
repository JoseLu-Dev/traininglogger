# Sync Architecture - Common Foundation

## Context

LiftLogger needs a sync endpoint architecture that:

1. **Maximizes genericity** - Adding new tables requires minimal code changes (1 line)
2. **Optimizes performance** - Handles large datasets efficiently via batching
3. **Maintains simplicity** - Easy to understand and maintain
4. **Scales gracefully** - Works from MVP to production with thousands of records
5. **Follows hexagonal architecture** - Proper separation of concerns (Domain → Application → Infrastructure)
6. **Handles partial failures** - Validates entities and returns failures without stopping sync
7. **Frontend-grouped requests** - Client groups entities by type for cleaner API

The application has 12 entity types with complex relationships and will grow over time.

## Hexagonal Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ INFRASTRUCTURE LAYER (Adapters)                             │
│  REST Controller → Use Case Ports                            │
│  JPA Adapters → Repository Ports                             │
│  MapStruct Mappers (DTO ↔ Domain, JPA ↔ Domain)            │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ APPLICATION LAYER (Use Cases & Business Logic)              │
│  Use Case Interfaces (Ports)                                 │
│  Use Case Implementations (Services)                         │
│  Entity Validators (Business Rules)                         │
│  Entity Metadata Registry (Generic Config)                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER (Pure Business Logic)                          │
│  Domain Entities (POJOs)                                     │
│  Repository Ports (Interfaces)                               │
│  Domain Exceptions                                           │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

**Domain Layer:**

- Pure POJOs (Lombok `@Getter`, `@Setter`, `@Builder`)
- No framework dependencies
- Repository interfaces (ports)
- Domain exceptions

**Application Layer:**

- Use case interfaces (input ports): `PullSyncUseCase`, `PushSyncUseCase`
- Use case implementations (services): `PullSyncService`, `PushSyncService`
- Business logic: Entity validators, metadata registry
- Orchestration: Parallel queries, batch processing

**Infrastructure Layer:**

- REST controllers: Call use case ports, return DTOs
- DTOs: Request/Response records
- MapStruct mappers: Domain ↔ DTO, JPA ↔ Domain
- JPA adapters: Implement repository ports

## Core Components

### 1. Entity Validator Interface

File: `application/sync/EntityValidator.java`

```java
public interface EntityValidator<T> {
    ValidationResult validate(T entity, ValidationContext context);
}

public record ValidationResult(
    boolean isValid,
    List<ValidationError> errors
) {
    public static ValidationResult success() {
        return new ValidationResult(true, List.of());
    }

    public static ValidationResult failure(List<ValidationError> errors) {
        return new ValidationResult(false, errors);
    }
}

public record ValidationError(
    String field,
    String code,
    String message
) {}

public record ValidationContext(
    UUID currentUserId,
    String currentUserRole
) {}
```

### 2. Entity Metadata Registry

File: `application/sync/EntitySyncMetadata.java`

```java
@Configuration
public class EntitySyncMetadata {

    @Autowired
    private TrainingPlanValidator trainingPlanValidator;

    @Autowired
    private SetSessionValidator setSessionValidator;

    @Autowired
    private ExerciseValidator exerciseValidator;

    @Bean
    public EntityRegistry entityRegistry() {
        return EntityRegistry.builder()
            // Entity class, Owner field, Validator
            .register(TrainingPlan.class, "athleteId", trainingPlanValidator)
            .register(SetSession.class, "athleteId", setSessionValidator)
            .register(Exercise.class, "coachId", exerciseValidator)
            // ... 9 more lines for other entities
            .build();
    }
}
```

File: `application/sync/EntityRegistry.java`

```java
@Component
public class EntityRegistry {
    private final Map<String, EntityMetadata<?>> registryByName = new HashMap<>();
    private final Map<Class<?>, EntityMetadata<?>> registryByClass = new HashMap<>();

    public <T> EntityRegistry register(Class<T> entityClass, String ownerField, EntityValidator<T> validator) {
        String entityName = entityClass.getSimpleName();
        EntityMetadata<T> metadata = new EntityMetadata<>(entityClass, entityName, ownerField, validator);
        registryByName.put(entityName, metadata);
        registryByClass.put(entityClass, metadata);
        return this;
    }

    public EntityMetadata<?> getByName(String entityName) {
        return registryByName.get(entityName);
    }

    public <T> EntityMetadata<T> getByClass(Class<T> entityClass) {
        return (EntityMetadata<T>) registryByClass.get(entityClass);
    }

    public List<String> getAllEntityNames() {
        return new ArrayList<>(registryByName.keySet());
    }
}

public record EntityMetadata<T>(
    Class<T> entityClass,
    String entityName,        // e.g., "TrainingPlan"
    String ownerField,        // e.g., "athleteId" or "coachId"
    EntityValidator<T> validator
) {}
```

### 3. Example Validator

File: `application/sync/validators/TrainingPlanValidator.java`

```java
@Component
public class TrainingPlanValidator implements EntityValidator<TrainingPlan> {

    private final TrainingPlanRepository repository;
    private final AthleteRepository athleteRepository;

    @Override
    public ValidationResult validate(TrainingPlan plan, ValidationContext ctx) {
        List<ValidationError> errors = new ArrayList<>();

        // Field validation
        if (plan.getName() == null || plan.getName().isBlank()) {
            errors.add(new ValidationError("name", "REQUIRED", "Name is required"));
        }

        if (plan.getStartDate().isAfter(plan.getEndDate())) {
            errors.add(new ValidationError("endDate", "INVALID_RANGE",
                "End date must be after start date"));
        }

        // Cross-entity validation (business rule)
        if (!athleteRepository.existsById(plan.getAthleteId())) {
            errors.add(new ValidationError("athleteId", "NOT_FOUND",
                "Athlete does not exist"));
        }

        // Business rule: No overlapping plans
        boolean hasOverlap = repository.existsOverlappingPlan(
            plan.getAthleteId(),
            plan.getStartDate(),
            plan.getEndDate(),
            plan.getId()
        );
        if (hasOverlap) {
            errors.add(new ValidationError("dateRange", "OVERLAP",
                "Another training plan exists in this date range"));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }
}
```

## Genericity: How It Works

### Adding New Entity (Step-by-Step Example)

Let's say you want to add `Nutrition` entity to sync:

**Step 1:** Create validator (optional, only if business rules needed)

```java
@Component
public class NutritionValidator implements EntityValidator<Nutrition> {
    @Override
    public ValidationResult validate(Nutrition nutrition, ValidationContext ctx) {
        List<ValidationError> errors = new ArrayList<>();

        if (nutrition.getCalories() < 0) {
            errors.add(new ValidationError("calories", "INVALID",
                "Calories cannot be negative"));
        }

        return errors.isEmpty()
            ? ValidationResult.success()
            : ValidationResult.failure(errors);
    }
}
```

**Step 2:** Register in metadata (1 line)

```java
@Configuration
public class EntitySyncMetadata {
    @Autowired private NutritionValidator nutritionValidator;

    @Bean
    public EntityRegistry entityRegistry() {
        return EntityRegistry.builder()
            .register(TrainingPlan.class, "athleteId", trainingPlanValidator)
            .register(SetSession.class, "athleteId", setSessionValidator)
            .register(Nutrition.class, "athleteId", nutritionValidator)  // ← ADD THIS LINE
            .build();
    }
}
```

**Step 3:** Done! The generic sync system automatically:

- ✅ Pulls `Nutrition` entities via JPA Criteria API query
- ✅ Pushes `Nutrition` entities with validation
- ✅ Maps to/from DTOs using MapStruct
- ✅ Returns partial failures if validation fails
- ✅ Batches saves for performance

## Next Steps

See detailed documentation for:

- **Pull endpoint:** `01-pull.md`
- **Push endpoint:** `02-push.md`
