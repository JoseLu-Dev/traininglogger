# Step 7: MapStruct Mappers

## Objective
Implement MapStruct mappers for converting between Domain ↔ JPA and Domain ↔ DTO layers.

## Dependencies

Add MapStruct to `pom.xml`:

```xml
<dependencies>
    <dependency>
        <groupId>org.mapstruct</groupId>
        <artifactId>mapstruct</artifactId>
        <version>1.5.5.Final</version>
    </dependency>
</dependencies>

<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.11.0</version>
            <configuration>
                <annotationProcessorPaths>
                    <path>
                        <groupId>org.mapstruct</groupId>
                        <artifactId>mapstruct-processor</artifactId>
                        <version>1.5.5.Final</version>
                    </path>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok</artifactId>
                        <version>1.18.30</version>
                    </path>
                    <path>
                        <groupId>org.projectlombok</groupId>
                        <artifactId>lombok-mapstruct-binding</artifactId>
                        <version>0.2.0</version>
                    </path>
                </annotationProcessorPaths>
            </configuration>
        </plugin>
    </plugins>
</build>
```

## Files to Create

### 1. Domain ↔ JPA Mapper

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/mapper/TrainingPlanMapper.java`

```java
package com.liftlogger.infrastructure.persistence.mapper;

import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.infrastructure.persistence.entity.TrainingPlanJpaEntity;
import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants;

import java.util.List;

/**
 * MapStruct mapper for TrainingPlan domain ↔ JPA entity
 */
@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface TrainingPlanMapper {

    TrainingPlan toDomain(TrainingPlanJpaEntity jpaEntity);

    TrainingPlanJpaEntity toJpa(TrainingPlan domain);

    List<TrainingPlan> toDomainList(List<TrainingPlanJpaEntity> jpaEntities);

    List<TrainingPlanJpaEntity> toJpaList(List<TrainingPlan> domainEntities);
}
```

**File:** `src/main/java/com/liftlogger/infrastructure/persistence/mapper/SetSessionMapper.java`

```java
package com.liftlogger.infrastructure.persistence.mapper;

import com.liftlogger.domain.entity.SetSession;
import com.liftlogger.infrastructure.persistence.entity.SetSessionJpaEntity;
import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants;

import java.util.List;

@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface SetSessionMapper {

    SetSession toDomain(SetSessionJpaEntity jpaEntity);

    SetSessionJpaEntity toJpa(SetSession domain);

    List<SetSession> toDomainList(List<SetSessionJpaEntity> jpaEntities);

    List<SetSessionJpaEntity> toJpaList(List<SetSession> domainEntities);
}
```

### 2. Domain ↔ DTO Mapper (for REST API)

**File:** `src/main/java/com/liftlogger/infrastructure/rest/dto/TrainingPlanDto.java`

```java
package com.liftlogger.infrastructure.rest.dto;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

/**
 * DTO for TrainingPlan exposed in REST API
 */
public record TrainingPlanDto(
    UUID id,
    UUID athleteId,
    String name,
    String description,

    @JsonFormat(pattern = "yyyy-MM-dd")
    LocalDate startDate,

    @JsonFormat(pattern = "yyyy-MM-dd")
    LocalDate endDate,

    String status,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime createdAt,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime updatedAt,

    UUID createdBy,
    UUID updatedBy
) {}
```

**File:** `src/main/java/com/liftlogger/infrastructure/rest/mapper/TrainingPlanDtoMapper.java`

```java
package com.liftlogger.infrastructure.rest.mapper;

import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.infrastructure.rest.dto.TrainingPlanDto;
import org.mapstruct.Mapper;
import org.mapstruct.MappingConstants;

import java.util.List;

/**
 * MapStruct mapper for TrainingPlan domain ↔ DTO
 */
@Mapper(componentModel = MappingConstants.ComponentModel.SPRING)
public interface TrainingPlanDtoMapper {

    TrainingPlanDto toDto(TrainingPlan domain);

    TrainingPlan toDomain(TrainingPlanDto dto);

    List<TrainingPlanDto> toDtoList(List<TrainingPlan> domainEntities);

    List<TrainingPlan> toDomainList(List<TrainingPlanDto> dtos);
}
```

### 3. Generic DTO Mapper Provider

**File:** `src/main/java/com/liftlogger/infrastructure/rest/mapper/DtoMapperProvider.java`

```java
package com.liftlogger.infrastructure.rest.mapper;

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

        // Try to find mapper bean by naming convention
        Map<String, ?> mappers = applicationContext.getBeansOfType(Object.class);
        for (Map.Entry<String, ?> entry : mappers.entrySet()) {
            if (entry.getKey().contains(mapperName)) {
                return entry.getValue();
            }
        }

        throw new IllegalArgumentException(
            "No DTO mapper found for domain class: " + domainClass.getName()
        );
    }
}
```

### 4. Sync DTO Converter

**File:** `src/main/java/com/liftlogger/infrastructure/rest/mapper/SyncDtoConverter.java`

```java
package com.liftlogger.infrastructure.rest.mapper;

import com.liftlogger.application.sync.EntityRegistry;
import com.liftlogger.application.sync.dto.PullSyncResponse;
import com.liftlogger.infrastructure.rest.dto.sync.PullSyncResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Converter for sync-specific DTOs that handles dynamic entity types
 */
@Component
@RequiredArgsConstructor
public class SyncDtoConverter {

    private final EntityRegistry entityRegistry;
    private final DtoMapperProvider dtoMapperProvider;

    /**
     * Convert PullSyncResponse (domain) to PullSyncResponseDto
     * Maps domain entities to DTOs for each entity type
     */
    public PullSyncResponseDto toPullResponseDto(PullSyncResponse response) {
        Map<String, List<Object>> dtoEntities = new HashMap<>();

        response.entities().forEach((entityType, domainEntities) -> {
            var metadata = entityRegistry.getByName(entityType);
            List<Object> dtos = dtoMapperProvider.toDtoList(
                domainEntities,
                metadata.entityClass()
            );
            dtoEntities.put(entityType, dtos);
        });

        return new PullSyncResponseDto(
            dtoEntities,
            response.syncTimestamp(),
            response.totalEntities()
        );
    }

    /**
     * Convert PushSyncRequestDto to domain entities
     */
    @SuppressWarnings("unchecked")
    public Map<String, List<Object>> toDomainEntities(Map<String, List<Object>> dtoEntities) {
        Map<String, List<Object>> domainEntities = new HashMap<>();

        dtoEntities.forEach((entityType, dtos) -> {
            var metadata = entityRegistry.getByName(entityType);
            List<Object> domains = dtoMapperProvider.toDomainList(
                dtos,
                metadata.entityClass()
            );
            domainEntities.put(entityType, domains);
        });

        return domainEntities;
    }
}
```

### 5. DTO for Sync Endpoints

**File:** `src/main/java/com/liftlogger/infrastructure/rest/dto/sync/PullSyncResponseDto.java`

```java
package com.liftlogger.infrastructure.rest.dto.sync;

import com.fasterxml.jackson.annotation.JsonFormat;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

public record PullSyncResponseDto(
    Map<String, List<Object>> entities,

    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss")
    LocalDateTime syncTimestamp,

    int totalEntities
) {}
```

## Testing

**File:** `src/test/java/com/liftlogger/infrastructure/persistence/mapper/TrainingPlanMapperTest.java`

```java
package com.liftlogger.infrastructure.persistence.mapper;

import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.infrastructure.persistence.entity.TrainingPlanJpaEntity;
import org.junit.jupiter.api.Test;
import org.mapstruct.factory.Mappers;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class TrainingPlanMapperTest {

    private final TrainingPlanMapper mapper = Mappers.getMapper(TrainingPlanMapper.class);

    @Test
    void toDomain_mapsAllFields() {
        TrainingPlanJpaEntity jpaEntity = TrainingPlanJpaEntity.builder()
            .id(UUID.randomUUID())
            .athleteId(UUID.randomUUID())
            .name("Test Plan")
            .description("Description")
            .startDate(LocalDate.of(2024, 1, 1))
            .endDate(LocalDate.of(2024, 1, 31))
            .status("ACTIVE")
            .build();
        jpaEntity.setCreatedAt(LocalDateTime.now());
        jpaEntity.setUpdatedAt(LocalDateTime.now());

        TrainingPlan domain = mapper.toDomain(jpaEntity);

        assertThat(domain.getId()).isEqualTo(jpaEntity.getId());
        assertThat(domain.getAthleteId()).isEqualTo(jpaEntity.getAthleteId());
        assertThat(domain.getName()).isEqualTo(jpaEntity.getName());
        assertThat(domain.getDescription()).isEqualTo(jpaEntity.getDescription());
        assertThat(domain.getStartDate()).isEqualTo(jpaEntity.getStartDate());
        assertThat(domain.getEndDate()).isEqualTo(jpaEntity.getEndDate());
        assertThat(domain.getStatus()).isEqualTo(jpaEntity.getStatus());
        assertThat(domain.getCreatedAt()).isEqualTo(jpaEntity.getCreatedAt());
        assertThat(domain.getUpdatedAt()).isEqualTo(jpaEntity.getUpdatedAt());
    }

    @Test
    void toJpa_mapsAllFields() {
        TrainingPlan domain = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(UUID.randomUUID())
            .name("Test Plan")
            .description("Description")
            .startDate(LocalDate.of(2024, 1, 1))
            .endDate(LocalDate.of(2024, 1, 31))
            .status("ACTIVE")
            .createdAt(LocalDateTime.now())
            .updatedAt(LocalDateTime.now())
            .build();

        TrainingPlanJpaEntity jpaEntity = mapper.toJpa(domain);

        assertThat(jpaEntity.getId()).isEqualTo(domain.getId());
        assertThat(jpaEntity.getAthleteId()).isEqualTo(domain.getAthleteId());
        assertThat(jpaEntity.getName()).isEqualTo(domain.getName());
        assertThat(jpaEntity.getStartDate()).isEqualTo(domain.getStartDate());
    }

    @Test
    void toDomain_roundTrip_preservesData() {
        TrainingPlan original = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(UUID.randomUUID())
            .name("Test Plan")
            .startDate(LocalDate.of(2024, 1, 1))
            .endDate(LocalDate.of(2024, 1, 31))
            .status("ACTIVE")
            .build();

        TrainingPlanJpaEntity jpaEntity = mapper.toJpa(original);
        TrainingPlan roundTrip = mapper.toDomain(jpaEntity);

        assertThat(roundTrip).usingRecursiveComparison().isEqualTo(original);
    }
}
```

## Acceptance Criteria

- ✅ MapStruct dependency configured with annotation processors
- ✅ Domain ↔ JPA mappers for all 12 entities
- ✅ Domain ↔ DTO mappers for all 12 entities
- ✅ `DtoMapperProvider` for dynamic mapper lookup
- ✅ `SyncDtoConverter` for sync-specific DTO conversion
- ✅ DTOs with proper JSON formatting (@JsonFormat)
- ✅ Mapper tests pass
- ✅ Round-trip conversion preserves data

## Mapper Checklist

Create mappers for these entities:

1. ✅ TrainingPlan
2. SetSession
3. Exercise
4. Workout
5. Athlete
6. Coach
7. MuscleGroup
8. Equipment
9. ExerciseCategory
10. ProgressPhoto
11. BodyMeasurement
12. NutritionLog

## Next Step

After completing this step, move to **08-rest-controllers.md** to implement the REST API endpoints.
