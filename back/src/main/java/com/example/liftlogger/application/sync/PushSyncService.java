package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.EntityFailure;
import com.example.liftlogger.application.sync.dto.PushSyncRequest;
import com.example.liftlogger.application.sync.dto.PushSyncResponse;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Service implementation for push sync use case
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PushSyncService implements PushSyncUseCase {

    private final EntityRegistry entityRegistry;
    private final RepositoryProvider repositoryProvider;
    private final UserContextProvider userContextProvider;

    @Override
    @Transactional
    public PushSyncResponse pushEntities(UUID userId, PushSyncRequest request) {
        log.info("Push sync requested for user {} with {} entities",
            userId, request.getTotalEntities());

        ValidationContext validationContext = userContextProvider.getValidationContext(userId);
        List<EntityFailure> failures = new ArrayList<>();
        AtomicInteger successCount = new AtomicInteger(0);

        // Process each entity type
        request.entities().forEach((entityType, entities) -> {
            processEntityType(
                entityType,
                entities,
                validationContext,
                successCount,
                failures
            );
        });

        Instant syncTimestamp = Instant.now();
        int failureCount = failures.size();

        log.info("Push sync completed for user {}: {} succeeded, {} failed",
            userId, successCount.get(), failureCount);

        return new PushSyncResponse(
            successCount.get(),
            failureCount,
            failures,
            syncTimestamp
        );
    }

    @SuppressWarnings("unchecked")
    private void processEntityType(
        String entityType,
        List<Object> entities,
        ValidationContext validationContext,
        AtomicInteger successCount,
        List<EntityFailure> failures
    ) {
        try {
            EntityMetadata<?> metadata = entityRegistry.getByName(entityType);
            GenericSyncRepository repository = repositoryProvider.getRepository(
                metadata.entityClass()
            );
            EntityValidator validator = metadata.validator();

            List<Object> validEntities = new ArrayList<>();

            // Validate each entity
            for (Object entity : entities) {
                UUID entityId = extractEntityId(entity);
                ValidationResult result = validator.validate(
                    entity,
                    validationContext
                );

                if (result.isValid()) {
                    validEntities.add(entity);
                } else {
                    failures.add(new EntityFailure(
                        entityType,
                        entityId,
                        result.errors()
                    ));
                    log.warn("Validation failed for {} with id {}: {}",
                        entityType, entityId, result.errors());
                }
            }

            // Batch save valid entities
            if (!validEntities.isEmpty()) {
                repository.saveAll(validEntities);
                successCount.addAndGet(validEntities.size());
                log.debug("Saved {} valid entities of type {}",
                    validEntities.size(), entityType);
            }

        } catch (Exception e) {
            log.error("Error processing entity type {}", entityType, e);
            // Add all entities of this type as failures
            entities.forEach(entity -> {
                UUID entityId = extractEntityId(entity);
                failures.add(new EntityFailure(
                    entityType,
                    entityId,
                    List.of(new ValidationError(
                        "general",
                        "PROCESSING_ERROR",
                        "Error processing entity: " + e.getMessage()
                    ))
                ));
            });
        }
    }

    /**
     * Extract entity ID using reflection
     */
    private UUID extractEntityId(Object entity) {
        try {
            var method = entity.getClass().getMethod("getId");
            return (UUID) method.invoke(entity);
        } catch (Exception e) {
            log.error("Failed to extract entity ID", e);
            return null;
        }
    }
}
