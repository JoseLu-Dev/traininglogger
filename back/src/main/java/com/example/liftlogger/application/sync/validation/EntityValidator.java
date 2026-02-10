package com.example.liftlogger.application.sync.validation;

/**
 * Generic validator interface for entity validation.
 * Each entity type has its own validator implementation.
 *
 * @param <T> The domain entity type
 */
public interface EntityValidator<T> {

    /**
     * Validate an entity with business rules
     *
     * @param entity The entity to validate
     * @param context User context for validation
     * @return ValidationResult with errors if validation fails
     */
    ValidationResult validate(T entity, ValidationContext context);
}
