package com.example.liftlogger.application.sync;

import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;

/**
 * Provider interface for getting repository instances by entity class.
 * Implementation will be in infrastructure layer.
 */
public interface RepositoryProvider {

    /**
     * Get repository for entity class
     *
     * @param entityClass The domain entity class
     * @return Repository instance for that entity
     */
    <T> GenericSyncRepository<T> getRepository(Class<T> entityClass);
}
