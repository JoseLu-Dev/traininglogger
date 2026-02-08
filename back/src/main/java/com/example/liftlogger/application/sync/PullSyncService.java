package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.PullSyncRequest;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Service implementation for pull sync use case
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PullSyncService implements PullSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final RepositoryProvider repositoryProvider;

    @Override
    @Transactional(readOnly = true)
    public PullSyncResponse pullEntities(UUID userId, PullSyncRequest request) {
        log.info("Pull sync requested for user {} with {} entity types, lastSyncTime={}",
            userId, request.entityTypes().size(), request.lastSyncTime());

        LocalDateTime syncTimestamp = LocalDateTime.now();
        Map<String, List<Object>> entitiesMap = new ConcurrentHashMap<>();

        // Process entity types in parallel
        List<CompletableFuture<Void>> futures = request.entityTypes().stream()
            .map(entityType -> CompletableFuture.runAsync(() -> {
                List<Object> entities = fetchEntitiesForType(
                    entityType,
                    userId,
                    request.lastSyncTime()
                );
                if (!entities.isEmpty()) {
                    entitiesMap.put(entityType, entities);
                }
            }))
            .toList();

        // Wait for all queries to complete
        CompletableFuture.allOf(futures.toArray(new CompletableFuture[0])).join();

        int totalEntities = entitiesMap.values().stream()
            .mapToInt(List::size)
            .sum();

        log.info("Pull sync completed for user {}: {} entities across {} types",
            userId, totalEntities, entitiesMap.size());

        return new PullSyncResponse(entitiesMap, syncTimestamp, totalEntities);
    }

    private List<Object> fetchEntitiesForType(
        String entityType,
        UUID userId,
        LocalDateTime lastSyncTime
    ) {
        try {
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            GenericSyncRepository<?> repository = repositoryProvider.getRepository(
                metadata.entityClass()
            );

            List<?> entities;
            if (lastSyncTime == null) {
                // Full sync - fetch all entities
                entities = repository.findByOwner(userId);
            } else {
                // Incremental sync - fetch only updated entities
                entities = repository.findByOwnerAndUpdatedAfter(userId, lastSyncTime);
            }

            log.debug("Fetched {} entities of type {} for user {}",
                entities.size(), entityType, userId);

            return new ArrayList<>(entities);

        } catch (Exception e) {
            log.error("Error fetching entities of type {} for user {}",
                entityType, userId, e);
            // Return empty list instead of failing entire sync
            return List.of();
        }
    }
}
