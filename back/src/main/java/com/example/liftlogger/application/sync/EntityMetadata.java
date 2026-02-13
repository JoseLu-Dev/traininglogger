package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.validation.EntityValidator;

/**
 * Metadata for an entity type in the sync system
 *
 * @param entityClass The domain entity class
 * @param entityName Simple name for API (e.g., "TrainingPlan")
 * @param ownerField Name of the owner field (e.g., "athleteId", "coachId")
 * @param ownershipType The ownership type determining visibility rules
 * @param validator The validator for this entity type
 */
public record EntityMetadata<T>(
    Class<T> entityClass,
    String entityName,
    String ownerField,
    OwnershipType ownershipType,
    EntityValidator<T> validator
) {}
