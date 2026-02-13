package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.validation.EntityValidator;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
     * @param ownershipType The ownership type determining visibility rules
     * @param validator The validator for this entity type
     * @return this registry for chaining
     */
    public <T> EntityRegistry register(
        Class<T> entityClass,
        String ownerField,
        OwnershipType ownershipType,
        EntityValidator<T> validator
    ) {
        String entityName = entityClass.getSimpleName();
        return register(entityClass, entityName, ownerField, ownershipType, validator);
    }

    /**
     * Register an entity type with a custom name (for DTOs that represent domain entities)
     *
     * @param entityClass The domain entity class or DTO class
     * @param entityName Custom name for API (e.g., "User" for UserSyncDto)
     * @param ownerField The field name that identifies the owner
     * @param ownershipType The ownership type determining visibility rules
     * @param validator The validator for this entity type
     * @return this registry for chaining
     */
    public <T> EntityRegistry register(
        Class<T> entityClass,
        String entityName,
        String ownerField,
        OwnershipType ownershipType,
        EntityValidator<T> validator
    ) {
        EntityMetadata<T> metadata = new EntityMetadata<>(
            entityClass,
            entityName,
            ownerField,
            ownershipType,
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
