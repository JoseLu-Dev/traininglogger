package com.example.liftlogger.infrastructure.rest.dto;

import java.time.Instant;
import java.util.UUID;

public record SetSessionDto(
    UUID id,
    UUID athleteId,
    UUID exerciseSessionId,
    UUID setPlanId,
    Integer setNumber,
    Integer actualReps,
    Double actualWeight,
    Double actualRpe,
    String notes,
    Instant createdAt,
    Instant updatedAt,
    UUID createdBy,
    UUID updatedBy,
    Instant deletedAt
) {}
