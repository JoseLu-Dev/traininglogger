package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record SetPlanDto(
    UUID id,
    UUID athleteId,
    UUID exercisePlanId,
    Integer setNumber,
    Integer targetReps,
    Double targetWeight,
    Double targetRpe,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
