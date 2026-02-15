package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record BodyWeightEntryDto(
    UUID id,
    UUID athleteId,
    Instant measurementDate,
    Double weight,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
