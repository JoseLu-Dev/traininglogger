package com.example.liftlogger.infrastructure.rest.dto.sync;

import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.validation.constraints.NotEmpty;

import java.time.LocalDateTime;
import java.util.List;

public record PullSyncRequestDto(
    @NotEmpty(message = "Entity types list cannot be empty")
    List<String> entityTypes,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime lastSyncTime
) {}
