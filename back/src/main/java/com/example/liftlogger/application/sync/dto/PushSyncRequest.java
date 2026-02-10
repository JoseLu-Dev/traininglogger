package com.example.liftlogger.application.sync.dto;

import java.util.List;
import java.util.Map;

/**
 * Request for pushing entities to server
 * Frontend groups entities by type for cleaner API
 *
 * @param entities Map of entityType -> list of entities
 */
public record PushSyncRequest(
    Map<String, List<Object>> entities
) {
    public int getTotalEntities() {
        return entities.values().stream()
            .mapToInt(List::size)
            .sum();
    }
}
