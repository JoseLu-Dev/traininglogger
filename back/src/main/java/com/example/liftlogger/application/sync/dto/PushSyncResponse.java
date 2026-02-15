package com.example.liftlogger.application.sync.dto;

import java.time.Instant;
import java.util.List;

/**
 * Response after pushing entities
 *
 * @param successCount Number of entities successfully saved
 * @param failureCount Number of entities that failed validation
 * @param failures List of validation failures with entity details
 * @param syncTimestamp Server timestamp after save
 */
public record PushSyncResponse(
    int successCount,
    int failureCount,
    List<EntityFailure> failures,
    Instant syncTimestamp
) {
    public boolean hasFailures() {
        return failureCount > 0;
    }

    public boolean isFullSuccess() {
        return failureCount == 0;
    }
}
