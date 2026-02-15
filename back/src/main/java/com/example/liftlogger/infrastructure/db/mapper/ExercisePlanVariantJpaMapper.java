package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.ExercisePlanVariant;
import com.example.liftlogger.infrastructure.db.entity.ExercisePlanVariantJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExercisePlanVariantJpaMapper {
    ExercisePlanVariant toDomain(ExercisePlanVariantJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    ExercisePlanVariantJpaEntity toJpa(ExercisePlanVariant domain);

    List<ExercisePlanVariant> toDomainList(List<ExercisePlanVariantJpaEntity> jpaEntities);
    List<ExercisePlanVariantJpaEntity> toJpaList(List<ExercisePlanVariant> domainEntities);
}
