package com.example.liftlogger.application.sync.validation;

import org.springframework.stereotype.Component;

/**
 * Validator that always returns success.
 * Use for entities that don't need custom validation.
 */
@Component
public class NoOpValidator<T> implements EntityValidator<T> {

    @Override
    public ValidationResult validate(T entity, ValidationContext context) {
        return ValidationResult.success();
    }
}
