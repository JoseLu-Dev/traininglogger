package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record TrainingPlanDto(
    UUID id,
    UUID athleteId,
    String name,
    LocalDate date,
    Boolean isLocked,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
