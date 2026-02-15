package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record TrainingPlanDto(
    UUID id,
    UUID athleteId,
    String name,
    Instant date,
    Boolean isLocked,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
