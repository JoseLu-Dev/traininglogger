package com.example.liftlogger.infrastructure.rest.dto;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.UUID;

public record SetPlanDto(
    UUID id,
    UUID athleteId,
    UUID exercisePlanId,
    Integer reps,
    Double weight,
    Integer orderIndex,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime createdAt,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime updatedAt,

    UUID createdBy,
    UUID updatedBy
) {}
