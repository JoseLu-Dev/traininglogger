package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record ExercisePlanVariantDto(
    UUID id,
    UUID athleteId,
    UUID exercisePlanId,
    UUID variantId,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
