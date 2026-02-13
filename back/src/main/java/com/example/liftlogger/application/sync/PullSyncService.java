package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.PullSyncRequest;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;
import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.model.UserRole;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
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
    private final UserRepository userRepository;

    @Override
    @Transactional(readOnly = true)
    public PullSyncResponse pullEntities(UUID userId, PullSyncRequest request) {
        log.info("Pull sync requested for user {} with {} entity types, lastSyncTime={}",
            userId, request.entityTypes().size(), request.lastSyncTime());

        // Fetch user to get role and coachId for ownership resolution
        User user = userRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        LocalDateTime syncTimestamp = LocalDateTime.now();
        Map<String, List<Object>> entitiesMap = new ConcurrentHashMap<>();

        // Process entity types in parallel
        List<CompletableFuture<Void>> futures = request.entityTypes().stream()
            .map(entityType -> CompletableFuture.runAsync(() -> {
                List<Object> entities = fetchEntitiesForType(
                    entityType,
                    user,
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
        User user,
        LocalDateTime lastSyncTime
    ) {
        try {
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            GenericSyncRepository<?> repository = repositoryProvider.getRepository(
                metadata.entityClass()
            );

            // Resolve owner IDs based on ownership type, user role, and coachId
            List<UUID> ownerIds = resolveOwnerIds(
                user.getId(),
                metadata.ownershipType(),
                user.getRole(),
                user.getCoachId()
            );

            if (ownerIds.isEmpty()) {
                log.debug("No owner IDs resolved for entity type {} and user {}",
                    entityType, user.getId());
                return List.of();
            }

            List<?> entities;
            if (lastSyncTime == null) {
                // Full sync - fetch all entities
                entities = repository.findByOwners(ownerIds);
            } else {
                // Incremental sync - fetch only updated entities
                entities = repository.findByOwnersAndUpdatedAfter(ownerIds, lastSyncTime);
            }

            log.debug("Fetched {} entities of type {} for user {}",
                entities.size(), entityType, user.getId());

            return new ArrayList<>(entities);

        } catch (Exception e) {
            log.error("Error fetching entities of type {} for user {}",
                entityType, user.getId(), e);
            // Return empty list instead of failing entire sync
            return List.of();
        }
    }

    /**
     * Resolve which owner IDs to query based on ownership type and user role.
     * Implements bi-directional visibility between coaches and athletes.
     */
    private List<UUID> resolveOwnerIds(
        UUID userId,
        OwnershipType ownershipType,
        UserRole userRole,
        UUID coachId
    ) {
        return switch (ownershipType) {
            case SELF -> {
                // Users only see their own User record
                yield List.of(userId);
            }

            case COACH -> {
                // Coach-owned entities (Exercise, Variant)
                if (userRole == UserRole.COACH) {
                    // Coaches see their own exercises
                    yield List.of(userId);
                } else {
                    // Athletes see their coach's exercises
                    if (coachId != null) {
                        yield List.of(coachId);
                    } else {
                        log.debug("Athlete {} has no coach, skipping COACH-owned entities", userId);
                        yield List.of();
                    }
                }
            }

            case ATHLETE -> {
                // Athlete-owned entities (TrainingPlan, Sessions, etc.)
                if (userRole == UserRole.ATHLETE) {
                    // Athletes see their own data
                    yield List.of(userId);
                } else {
                    // Coaches see all their athletes' data
                    List<UUID> athleteIds = userRepository.findAthleteIdsByCoachId(userId);
                    if (athleteIds.isEmpty()) {
                        log.debug("Coach {} has no athletes, skipping ATHLETE-owned entities", userId);
                    }
                    yield athleteIds;
                }
            }
        };
    }
}
