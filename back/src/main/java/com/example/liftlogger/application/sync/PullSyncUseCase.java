package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.PullSyncRequest;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;

import java.util.UUID;

/**
 * Use case port for pulling entities from server
 */
public interface PullSyncUseCase {

    /**
     * Pull entities for a user based on lastSyncTime
     *
     * @param userId The user requesting the sync
     * @param request The pull sync request with entity types and lastSyncTime
     * @return Response containing entities grouped by type
     */
    PullSyncResponse pullEntities(UUID userId, PullSyncRequest request);
}
