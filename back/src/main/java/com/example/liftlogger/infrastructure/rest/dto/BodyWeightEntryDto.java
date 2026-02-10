package com.example.liftlogger.infrastructure.rest.dto;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

public record BodyWeightEntryDto(
    UUID id,
    UUID athleteId,

    @JsonFormat(pattern = "yyyy-MM-dd")
    LocalDate date,

    Double weight,
    String notes,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime createdAt,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime updatedAt,

    UUID createdBy,
    UUID updatedBy
) {}
