# Step 3: Entity Registry

## Objective
Create the entity metadata registry that makes the sync system generic - adding new entities requires only 1 line of configuration.

## Files to Create

### 1. Entity Metadata Record

**File:** `src/main/java/com/liftlogger/application/sync/EntityMetadata.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.validation.EntityValidator;

/**
 * Metadata for an entity type in the sync system
 *
 * @param entityClass The domain entity class
 * @param entityName Simple name for API (e.g., "TrainingPlan")
 * @param ownerField Name of the owner field (e.g., "athleteId", "coachId")
 * @param validator The validator for this entity type
 */
public record EntityMetadata<T>(
    Class<T> entityClass,
    String entityName,
    String ownerField,
    EntityValidator<T> validator
) {}
```

### 2. Entity Registry

**File:** `src/main/java/com/liftlogger/application/sync/EntityRegistry.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.validation.EntityValidator;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * Central registry for all syncable entities.
 * Provides metadata lookup by name or class.
 */
@Component
public class EntityRegistry {

    private final Map<String, EntityMetadata<?>> registryByName = new HashMap<>();
    private final Map<Class<?>, EntityMetadata<?>> registryByClass = new HashMap<>();

    /**
     * Register an entity type with the sync system
     *
     * @param entityClass The domain entity class
     * @param ownerField The field name that identifies the owner (e.g., "athleteId")
     * @param validator The validator for this entity type
     * @return this registry for chaining
     */
    public <T> EntityRegistry register(
        Class<T> entityClass,
        String ownerField,
        EntityValidator<T> validator
    ) {
        String entityName = entityClass.getSimpleName();
        EntityMetadata<T> metadata = new EntityMetadata<>(
            entityClass,
            entityName,
            ownerField,
            validator
        );

        registryByName.put(entityName, metadata);
        registryByClass.put(entityClass, metadata);

        return this;
    }

    /**
     * Get metadata by entity name (e.g., "TrainingPlan")
     */
    public EntityMetadata<?> getByName(String entityName) {
        EntityMetadata<?> metadata = registryByName.get(entityName);
        if (metadata == null) {
            throw new IllegalArgumentException("Unknown entity type: " + entityName);
        }
        return metadata;
    }

    /**
     * Get metadata by entity class
     */
    @SuppressWarnings("unchecked")
    public <T> EntityMetadata<T> getByClass(Class<T> entityClass) {
        EntityMetadata<?> metadata = registryByClass.get(entityClass);
        if (metadata == null) {
            throw new IllegalArgumentException(
                "Unknown entity class: " + entityClass.getName()
            );
        }
        return (EntityMetadata<T>) metadata;
    }

    /**
     * Get all registered entity names
     */
    public List<String> getAllEntityNames() {
        return new ArrayList<>(registryByName.keySet());
    }

    /**
     * Check if entity type is registered
     */
    public boolean isRegistered(String entityName) {
        return registryByName.containsKey(entityName);
    }

    /**
     * Get count of registered entities
     */
    public int getEntityCount() {
        return registryByName.size();
    }
}
```

### 3. Entity Sync Configuration

**File:** `src/main/java/com/liftlogger/application/sync/EntitySyncConfiguration.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.validation.EntityValidator;
import com.liftlogger.application.sync.validation.NoOpValidator;
import com.liftlogger.domain.entity.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuration for all syncable entities.
 *
 * TO ADD A NEW ENTITY:
 * 1. Create validator (or use NoOpValidator)
 * 2. Add @Autowired field for validator
 * 3. Add .register() line in entityRegistry() method
 */
@Configuration
public class EntitySyncConfiguration {

    // Validators will be auto-wired as we create them
    // For now, we'll use NoOpValidator as placeholder

    @Autowired
    private NoOpValidator<?> noOpValidator;

    // TODO: Add specific validators as they're created
    // @Autowired private TrainingPlanValidator trainingPlanValidator;
    // @Autowired private SetSessionValidator setSessionValidator;

    @Bean
    public EntityRegistry entityRegistry() {
        EntityRegistry registry = new EntityRegistry();

        // Register all 12 entity types
        // Format: .register(EntityClass.class, "ownerField", validator)

        registry.register(TrainingPlan.class, "athleteId", noOpValidator);
        registry.register(SetSession.class, "athleteId", noOpValidator);
        registry.register(Exercise.class, "coachId", noOpValidator);
        registry.register(Workout.class, "athleteId", noOpValidator);
        registry.register(Athlete.class, "id", noOpValidator);  // Owner is self
        registry.register(Coach.class, "id", noOpValidator);    // Owner is self
        registry.register(MuscleGroup.class, "coachId", noOpValidator);
        registry.register(Equipment.class, "coachId", noOpValidator);
        registry.register(ExerciseCategory.class, "coachId", noOpValidator);
        registry.register(ProgressPhoto.class, "athleteId", noOpValidator);
        registry.register(BodyMeasurement.class, "athleteId", noOpValidator);
        registry.register(NutritionLog.class, "athleteId", noOpValidator);

        return registry;
    }
}
```

## Testing

**File:** `src/test/java/com/liftlogger/application/sync/EntityRegistryTest.java`

```java
package com.liftlogger.application.sync;

import com.liftlogger.application.sync.validation.EntityValidator;
import com.liftlogger.application.sync.validation.NoOpValidator;
import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.domain.entity.SetSession;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class EntityRegistryTest {

    private EntityRegistry registry;
    private EntityValidator<?> validator;

    @BeforeEach
    void setUp() {
        registry = new EntityRegistry();
        validator = new NoOpValidator<>();
    }

    @Test
    void register_storesMetadata() {
        registry.register(TrainingPlan.class, "athleteId", validator);

        assertThat(registry.getEntityCount()).isEqualTo(1);
        assertThat(registry.isRegistered("TrainingPlan")).isTrue();
    }

    @Test
    void getByName_returnsMetadata() {
        registry.register(TrainingPlan.class, "athleteId", validator);

        EntityMetadata<?> metadata = registry.getByName("TrainingPlan");

        assertThat(metadata.entityClass()).isEqualTo(TrainingPlan.class);
        assertThat(metadata.entityName()).isEqualTo("TrainingPlan");
        assertThat(metadata.ownerField()).isEqualTo("athleteId");
        assertThat(metadata.validator()).isEqualTo(validator);
    }

    @Test
    void getByClass_returnsMetadata() {
        registry.register(TrainingPlan.class, "athleteId", validator);

        EntityMetadata<TrainingPlan> metadata = registry.getByClass(TrainingPlan.class);

        assertThat(metadata.entityClass()).isEqualTo(TrainingPlan.class);
        assertThat(metadata.ownerField()).isEqualTo("athleteId");
    }

    @Test
    void getByName_unknownEntity_throwsException() {
        assertThatThrownBy(() -> registry.getByName("UnknownEntity"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Unknown entity type");
    }

    @Test
    void getAllEntityNames_returnsAllNames() {
        registry.register(TrainingPlan.class, "athleteId", validator);
        registry.register(SetSession.class, "athleteId", validator);

        List<String> names = registry.getAllEntityNames();

        assertThat(names).containsExactlyInAnyOrder("TrainingPlan", "SetSession");
    }

    @Test
    void register_supportsChaining() {
        EntityRegistry result = registry
            .register(TrainingPlan.class, "athleteId", validator)
            .register(SetSession.class, "athleteId", validator);

        assertThat(result).isSameAs(registry);
        assertThat(registry.getEntityCount()).isEqualTo(2);
    }
}
```

## Configuration Test

**File:** `src/test/java/com/liftlogger/application/sync/EntitySyncConfigurationTest.java`

```java
package com.liftlogger.application.sync;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class EntitySyncConfigurationTest {

    @Autowired
    private EntityRegistry entityRegistry;

    @Test
    void entityRegistry_hasAllEntities() {
        // Verify all 12 entities are registered
        assertThat(entityRegistry.getEntityCount()).isEqualTo(12);

        assertThat(entityRegistry.isRegistered("TrainingPlan")).isTrue();
        assertThat(entityRegistry.isRegistered("SetSession")).isTrue();
        assertThat(entityRegistry.isRegistered("Exercise")).isTrue();
        assertThat(entityRegistry.isRegistered("Workout")).isTrue();
        assertThat(entityRegistry.isRegistered("Athlete")).isTrue();
        assertThat(entityRegistry.isRegistered("Coach")).isTrue();
        assertThat(entityRegistry.isRegistered("MuscleGroup")).isTrue();
        assertThat(entityRegistry.isRegistered("Equipment")).isTrue();
        assertThat(entityRegistry.isRegistered("ExerciseCategory")).isTrue();
        assertThat(entityRegistry.isRegistered("ProgressPhoto")).isTrue();
        assertThat(entityRegistry.isRegistered("BodyMeasurement")).isTrue();
        assertThat(entityRegistry.isRegistered("NutritionLog")).isTrue();
    }

    @Test
    void entityRegistry_hasCorrectOwnerFields() {
        assertThat(entityRegistry.getByName("TrainingPlan").ownerField())
            .isEqualTo("athleteId");
        assertThat(entityRegistry.getByName("Exercise").ownerField())
            .isEqualTo("coachId");
        assertThat(entityRegistry.getByName("Athlete").ownerField())
            .isEqualTo("id");
    }
}
```

## Acceptance Criteria

- ✅ `EntityMetadata<T>` record stores entity configuration
- ✅ `EntityRegistry` provides lookup by name and class
- ✅ `EntitySyncConfiguration` registers all 12 entities
- ✅ Adding new entity only requires 1 line in configuration
- ✅ Registry throws clear exceptions for unknown entities
- ✅ Tests pass for registry functionality
- ✅ Spring Boot integration test verifies all entities are registered

## Next Step

After completing this step, move to **04-pull-use-case.md** to implement the pull sync logic.
