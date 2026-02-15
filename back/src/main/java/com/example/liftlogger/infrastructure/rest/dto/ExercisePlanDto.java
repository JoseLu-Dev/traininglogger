package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record ExercisePlanDto(
    UUID id,
    UUID athleteId,
    UUID trainingPlanId,
    UUID exerciseId,
    Integer orderIndex,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
