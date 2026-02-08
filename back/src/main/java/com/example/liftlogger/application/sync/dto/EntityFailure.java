package com.example.liftlogger.application.sync.dto;

import com.example.liftlogger.application.sync.validation.ValidationError;

import java.util.List;
import java.util.UUID;

/**
 * Details of a failed entity validation
 *
 * @param entityType The entity type (e.g., "TrainingPlan")
 * @param entityId The entity ID that failed
 * @param errors List of validation errors
 */
public record EntityFailure(
    String entityType,
    UUID entityId,
    List<ValidationError> errors
) {}
