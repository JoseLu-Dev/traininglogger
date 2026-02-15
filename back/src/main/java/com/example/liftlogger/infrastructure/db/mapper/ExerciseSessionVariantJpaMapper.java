package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.ExerciseSessionVariant;
import com.example.liftlogger.infrastructure.db.entity.ExerciseSessionVariantJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExerciseSessionVariantJpaMapper {
    ExerciseSessionVariant toDomain(ExerciseSessionVariantJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    ExerciseSessionVariantJpaEntity toJpa(ExerciseSessionVariant domain);

    List<ExerciseSessionVariant> toDomainList(List<ExerciseSessionVariantJpaEntity> jpaEntities);
    List<ExerciseSessionVariantJpaEntity> toJpaList(List<ExerciseSessionVariant> domainEntities);
}
