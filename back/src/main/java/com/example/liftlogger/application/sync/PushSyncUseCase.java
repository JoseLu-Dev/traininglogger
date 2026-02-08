package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.PushSyncRequest;
import com.example.liftlogger.application.sync.dto.PushSyncResponse;

import java.util.UUID;

/**
 * Use case port for pushing entities to server
 */
public interface PushSyncUseCase {

    /**
     * Validate and save entities for a user
     *
     * @param userId The user pushing the entities
     * @param request The push sync request with entities grouped by type
     * @return Response with success/failure counts and validation errors
     */
    PushSyncResponse pushEntities(UUID userId, PushSyncRequest request);
}
