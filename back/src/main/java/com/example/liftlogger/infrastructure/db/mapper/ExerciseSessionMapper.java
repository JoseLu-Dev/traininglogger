package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.ExerciseSession;
import com.example.liftlogger.infrastructure.db.entity.ExerciseSessionJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExerciseSessionMapper {
    ExerciseSession toDomain(ExerciseSessionJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    ExerciseSessionJpaEntity toJpa(ExerciseSession domain);

    List<ExerciseSession> toDomainList(List<ExerciseSessionJpaEntity> jpaEntities);
    List<ExerciseSessionJpaEntity> toJpaList(List<ExerciseSession> domainEntities);
}
