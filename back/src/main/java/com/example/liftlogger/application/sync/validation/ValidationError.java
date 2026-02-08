package com.example.liftlogger.application.sync.validation;

public record ValidationError(
    String field,
    String code,
    String message
) {
    public static ValidationError required(String field) {
        return new ValidationError(field, "REQUIRED", field + " is required");
    }

    public static ValidationError invalid(String field, String message) {
        return new ValidationError(field, "INVALID", message);
    }

    public static ValidationError notFound(String field, String entityType) {
        return new ValidationError(field, "NOT_FOUND", entityType + " not found");
    }

    public static ValidationError conflict(String field, String message) {
        return new ValidationError(field, "CONFLICT", message);
    }
}
