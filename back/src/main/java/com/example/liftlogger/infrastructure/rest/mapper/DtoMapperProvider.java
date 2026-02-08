package com.example.liftlogger.infrastructure.rest.mapper;

import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Provider for getting DTO mappers by entity class.
 * Uses reflection to find and cache mappers.
 */
@Component
public class DtoMapperProvider {

    private final ApplicationContext applicationContext;
    private final Map<Class<?>, Object> mapperCache = new ConcurrentHashMap<>();

    public DtoMapperProvider(ApplicationContext applicationContext) {
        this.applicationContext = applicationContext;
    }

    /**
     * Convert domain entity to DTO
     */
    @SuppressWarnings("unchecked")
    public <D, T> T toDto(D domainEntity, Class<D> domainClass) {
        Object mapper = getMapper(domainClass);
        try {
            var method = mapper.getClass().getMethod("toDto", domainClass);
            return (T) method.invoke(mapper, domainEntity);
        } catch (Exception e) {
            throw new RuntimeException("Failed to map to DTO: " + domainClass.getName(), e);
        }
    }

    /**
     * Convert DTO to domain entity
     */
    @SuppressWarnings("unchecked")
    public <D, T> D toDomain(T dto, Class<D> domainClass) {
        Object mapper = getMapper(domainClass);
        try {
            var method = mapper.getClass().getMethod("toDomain", dto.getClass());
            return (D) method.invoke(mapper, dto);
        } catch (Exception e) {
            throw new RuntimeException("Failed to map to domain: " + domainClass.getName(), e);
        }
    }

    /**
     * Convert list of domain entities to DTOs
     */
    @SuppressWarnings("unchecked")
    public <D, T> List<T> toDtoList(List<D> domainEntities, Class<D> domainClass) {
        if (domainEntities == null || domainEntities.isEmpty()) {
            return List.of();
        }

        Object mapper = getMapper(domainClass);
        try {
            var method = mapper.getClass().getMethod("toDtoList", List.class);
            return (List<T>) method.invoke(mapper, domainEntities);
        } catch (Exception e) {
            throw new RuntimeException("Failed to map list to DTO: " + domainClass.getName(), e);
        }
    }

    /**
     * Convert list of DTOs to domain entities
     */
    @SuppressWarnings("unchecked")
    public <D, T> List<D> toDomainList(List<T> dtos, Class<D> domainClass) {
        if (dtos == null || dtos.isEmpty()) {
            return List.of();
        }

        Object mapper = getMapper(domainClass);
        try {
            var method = mapper.getClass().getMethod("toDomainList", List.class);
            return (List<D>) method.invoke(mapper, dtos);
        } catch (Exception e) {
            throw new RuntimeException("Failed to map list to domain: " + domainClass.getName(), e);
        }
    }

    private Object getMapper(Class<?> domainClass) {
        return mapperCache.computeIfAbsent(domainClass, this::findMapper);
    }

    private Object findMapper(Class<?> domainClass) {
        String mapperName = domainClass.getSimpleName() + "DtoMapper";

        Map<String, ?> beans = applicationContext.getBeansOfType(Object.class);
        for (Map.Entry<String, ?> entry : beans.entrySet()) {
            if (entry.getKey().toLowerCase().contains(mapperName.toLowerCase())) {
                return entry.getValue();
            }
        }

        throw new IllegalArgumentException(
            "No DTO mapper found for domain class: " + domainClass.getName()
        );
    }
}
