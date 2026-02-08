package com.example.liftlogger.domain.outbound.repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Generic repository interface for sync operations.
 * All entity-specific repositories extend this.
 */
public interface GenericSyncRepository<T> {

    /**
     * Find entities owned by user, updated after lastSyncTime
     */
    List<T> findByOwnerAndUpdatedAfter(UUID ownerId, LocalDateTime lastSyncTime);

    /**
     * Find entities owned by user, all records
     */
    List<T> findByOwner(UUID ownerId);

    /**
     * Save entity (create or update)
     */
    T save(T entity);

    /**
     * Save multiple entities in batch
     */
    List<T> saveAll(List<T> entities);

    /**
     * Check if entity exists by ID
     */
    boolean existsById(UUID id);

    /**
     * Find entity by ID
     */
    T findById(UUID id);
}
