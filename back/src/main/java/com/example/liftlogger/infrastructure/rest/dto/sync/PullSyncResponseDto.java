package com.example.liftlogger.infrastructure.rest.dto.sync;

import java.time.Instant;
import java.util.List;
import java.util.Map;

public record PullSyncResponseDto(
    Map<String, List<Object>> entities,
    Instant syncTimestamp,
    int totalEntities
) {}
