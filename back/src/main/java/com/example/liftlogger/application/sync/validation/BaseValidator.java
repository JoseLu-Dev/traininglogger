package com.example.liftlogger.application.sync.validation;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Base class with common validation helpers
 */
public abstract class BaseValidator {

    protected List<ValidationError> errors = new ArrayList<>();

    protected void required(Object value, String field) {
        if (value == null) {
            errors.add(ValidationError.required(field));
        }
    }

    protected void requiredString(String value, String field) {
        if (value == null || value.isBlank()) {
            errors.add(ValidationError.required(field));
        }
    }

    protected void requiredUUID(UUID value, String field) {
        if (value == null) {
            errors.add(ValidationError.required(field));
        }
    }

    protected void minLength(String value, int min, String field) {
        if (value != null && value.length() < min) {
            errors.add(ValidationError.invalid(field,
                field + " must be at least " + min + " characters"));
        }
    }

    protected void maxLength(String value, int max, String field) {
        if (value != null && value.length() > max) {
            errors.add(ValidationError.invalid(field,
                field + " must be at most " + max + " characters"));
        }
    }

    protected void min(Number value, Number min, String field) {
        if (value != null && value.doubleValue() < min.doubleValue()) {
            errors.add(ValidationError.invalid(field,
                field + " must be at least " + min));
        }
    }

    protected void max(Number value, Number max, String field) {
        if (value != null && value.doubleValue() > max.doubleValue()) {
            errors.add(ValidationError.invalid(field,
                field + " must be at most " + max));
        }
    }

    protected void dateRange(LocalDate start, LocalDate end, String field) {
        if (start != null && end != null && start.isAfter(end)) {
            errors.add(ValidationError.invalid(field,
                "Start date must be before end date"));
        }
    }

    protected void dateTimeRange(LocalDateTime start, LocalDateTime end, String field) {
        if (start != null && end != null && start.isAfter(end)) {
            errors.add(ValidationError.invalid(field,
                "Start date/time must be before end date/time"));
        }
    }

    protected ValidationResult buildResult() {
        if (errors.isEmpty()) {
            return ValidationResult.success();
        }
        return ValidationResult.failure(errors);
    }

    protected void clearErrors() {
        errors.clear();
    }
}
