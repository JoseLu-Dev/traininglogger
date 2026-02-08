package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.Exercise;
import com.example.liftlogger.infrastructure.db.entity.ExerciseJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExerciseMapper {
    Exercise toDomain(ExerciseJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    ExerciseJpaEntity toJpa(Exercise domain);

    List<Exercise> toDomainList(List<ExerciseJpaEntity> jpaEntities);
    List<ExerciseJpaEntity> toJpaList(List<Exercise> domainEntities);
}
