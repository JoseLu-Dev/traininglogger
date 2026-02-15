package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record ExerciseSessionDto(
    UUID id,
    UUID athleteId,
    UUID trainingSessionId,
    UUID exercisePlanId,
    UUID exerciseId,
    Integer orderIndex,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
