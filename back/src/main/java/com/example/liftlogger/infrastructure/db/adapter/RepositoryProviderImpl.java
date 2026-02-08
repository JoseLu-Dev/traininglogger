package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.application.sync.RepositoryProvider;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Spring-based repository provider that looks up repositories from application context
 */
@Component
@RequiredArgsConstructor
public class RepositoryProviderImpl implements RepositoryProvider {

    private final ApplicationContext applicationContext;
    private final Map<Class<?>, GenericSyncRepository<?>> repositoryCache = new ConcurrentHashMap<>();

    @Override
    @SuppressWarnings("unchecked")
    public <T> GenericSyncRepository<T> getRepository(Class<T> entityClass) {
        return (GenericSyncRepository<T>) repositoryCache.computeIfAbsent(
            entityClass,
            this::findRepository
        );
    }

    @SuppressWarnings("rawtypes")
    private GenericSyncRepository<?> findRepository(Class<?> entityClass) {
        Map<String, GenericSyncRepository> repositories =
            applicationContext.getBeansOfType(GenericSyncRepository.class);

        for (GenericSyncRepository<?> repository : repositories.values()) {
            if (repository instanceof GenericJpaSyncAdapter<?, ?> adapter) {
                if (adapter.getDomainEntityClass().equals(entityClass)) {
                    return repository;
                }
            }
        }

        throw new IllegalArgumentException(
            "No repository found for entity class: " + entityClass.getName()
        );
    }
}
