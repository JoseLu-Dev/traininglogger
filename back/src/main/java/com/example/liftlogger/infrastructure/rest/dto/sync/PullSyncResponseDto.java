package com.example.liftlogger.infrastructure.rest.dto.sync;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public record PullSyncResponseDto(
    Map<String, List<Object>> entities,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime syncTimestamp,

    int totalEntities
) {}
