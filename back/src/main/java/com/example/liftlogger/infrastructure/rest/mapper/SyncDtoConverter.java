package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.application.sync.EntityRegistry;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;
import com.example.liftlogger.infrastructure.rest.dto.sync.PullSyncResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import tools.jackson.databind.ObjectMapper;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Converter for sync-specific DTOs that handles dynamic entity types.
 * Jackson deserializes {@code List<Object>} into {@code LinkedHashMap} entries,
 * so each item must be converted to the proper DTO type before the MapStruct
 * mapper can translate it to the domain model.
 */
@Component
@RequiredArgsConstructor
public class SyncDtoConverter {

    private final EntityRegistry entityRegistry;
    private final DtoMapperProvider dtoMapperProvider;
    private final ObjectMapper objectMapper;

    /**
     * Convert PullSyncResponse (domain) to PullSyncResponseDto
     * Maps domain entities to DTOs for each entity type
     */
    public PullSyncResponseDto toPullResponseDto(PullSyncResponse response) {
        Map<String, List<Object>> dtoEntities = new HashMap<>();

        response.entities().forEach((entityType, domainEntities) ->
            dtoEntities.put(entityType, convertToDtoList(entityType, domainEntities))
        );

        return new PullSyncResponseDto(
            dtoEntities,
            response.syncTimestamp(),
            response.totalEntities()
        );
    }

    @SuppressWarnings({"unchecked", "rawtypes"})
    private List<Object> convertToDtoList(String entityType, List<Object> domainEntities) {
        Class entityClass = entityRegistry.getByName(entityType).entityClass();

        // If the entity is already a DTO (e.g., UserSyncDto), return as-is
        if (isAlreadyDto(entityClass)) {
            return domainEntities;
        }

        return dtoMapperProvider.toDtoList(domainEntities, entityClass);
    }

    /**
     * Check if the class is already a DTO (no conversion needed)
     * DTOs from application.sync.dto package are already serialization-ready
     */
    private boolean isAlreadyDto(Class<?> clazz) {
        return clazz.getPackageName().startsWith("com.example.liftlogger.application.sync.dto");
    }

    /**
     * Convert push request DTO entities to domain entities.
     * Items arriving as {@code LinkedHashMap} (from JSON) are converted to the
     * proper DTO class using {@code ObjectMapper} before the MapStruct mapper runs.
     */
    public Map<String, List<Object>> toDomainEntities(Map<String, List<Object>> dtoEntities) {
        Map<String, List<Object>> domainEntities = new HashMap<>();

        dtoEntities.forEach((entityType, rawItems) ->
            domainEntities.put(entityType, convertToDomainList(entityType, rawItems))
        );

        return domainEntities;
    }

    @SuppressWarnings({"unchecked", "rawtypes"})
    private List<Object> convertToDomainList(String entityType, List<Object> rawItems) {
        Class entityClass = entityRegistry.getByName(entityType).entityClass();

        // If the entity is already a DTO (e.g., UserSyncDto), convert from raw JSON directly
        if (isAlreadyDto(entityClass)) {
            return rawItems.stream()
                .map(item -> objectMapper.convertValue(item, entityClass))
                .toList();
        }

        // Convert each raw item (typically LinkedHashMap from JSON) to the proper DTO type
        List typedDtos = rawItems.stream()
            .map(item -> convertToDto(item, entityClass))
            .toList();
        return dtoMapperProvider.toDomainList(typedDtos, entityClass);
    }

    /**
     * Converts a raw deserialized object (e.g. LinkedHashMap) to the DTO class
     * corresponding to the given domain entity class.
     * The DTO class is resolved by convention: {@code {EntityName}Dto} in the
     * {@code infrastructure.rest.dto} package.
     */
    private Object convertToDto(Object rawItem, Class<?> entityClass) {
        try {
            String dtoClassName = "com.example.liftlogger.infrastructure.rest.dto."
                    + entityClass.getSimpleName() + "Dto";
            Class<?> dtoClass = Class.forName(dtoClassName);
            return objectMapper.convertValue(rawItem, dtoClass);
        } catch (ClassNotFoundException e) {
            throw new IllegalArgumentException(
                "No DTO class found for entity: " + entityClass.getSimpleName(), e);
        }
    }
}
