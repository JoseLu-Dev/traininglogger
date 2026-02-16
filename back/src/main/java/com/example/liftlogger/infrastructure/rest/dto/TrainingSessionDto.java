package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

public record TrainingSessionDto(
    UUID id,
    UUID athleteId,
    UUID trainingPlanId,
    LocalDate sessionDate,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
