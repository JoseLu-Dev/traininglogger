package com.example.liftlogger.application.sync.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Response containing pulled entities grouped by type
 *
 * @param entities Map of entityType -> list of entities
 * @param syncTimestamp Server timestamp to use for next sync
 * @param totalEntities Total count of entities pulled
 */
public record PullSyncResponse(
    Map<String, List<Object>> entities,
    LocalDateTime syncTimestamp,
    int totalEntities
) {}
