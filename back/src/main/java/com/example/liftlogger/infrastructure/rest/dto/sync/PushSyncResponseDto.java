package com.example.liftlogger.infrastructure.rest.dto.sync;

import com.example.liftlogger.application.sync.dto.EntityFailure;

import java.time.Instant;
import java.util.List;

public record PushSyncResponseDto(
    int successCount,
    int failureCount,
    List<EntityFailure> failures,
    Instant syncTimestamp
) {}
