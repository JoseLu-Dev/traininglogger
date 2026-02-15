package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record ExerciseSessionVariantDto(
    UUID id,
    UUID athleteId,
    UUID exerciseSessionId,
    UUID variantId,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
