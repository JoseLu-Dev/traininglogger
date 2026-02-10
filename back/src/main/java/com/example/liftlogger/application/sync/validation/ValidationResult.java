package com.example.liftlogger.application.sync.validation;

import java.util.List;

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

    public static ValidationResult failure(ValidationError error) {
        return new ValidationResult(false, List.of(error));
    }
}
