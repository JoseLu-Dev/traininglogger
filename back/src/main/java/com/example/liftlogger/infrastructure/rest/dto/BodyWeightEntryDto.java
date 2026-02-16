package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record BodyWeightEntryDto(
    UUID id,
    UUID athleteId,
    LocalDate measurementDate,
    Double weight,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
