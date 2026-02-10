package com.example.liftlogger.infrastructure.rest.dto.sync;

import com.example.liftlogger.application.sync.dto.EntityFailure;
import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.List;

public record PushSyncResponseDto(
    int successCount,
    int failureCount,
    List<EntityFailure> failures,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime syncTimestamp
) {}
