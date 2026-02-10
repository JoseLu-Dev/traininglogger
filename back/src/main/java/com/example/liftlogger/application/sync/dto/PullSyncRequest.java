package com.example.liftlogger.application.sync.dto;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Request for pulling entities from server
 *
 * @param entityTypes List of entity types to pull (e.g., ["TrainingPlan", "SetSession"])
 * @param lastSyncTime Optional timestamp - only fetch entities updated after this time
 */
public record PullSyncRequest(
    List<String> entityTypes,
    LocalDateTime lastSyncTime  // null means fetch all
) {
    public boolean isFullSync() {
        return lastSyncTime == null;
    }
}
