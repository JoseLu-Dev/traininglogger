package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.ExercisePlan;
import com.example.liftlogger.infrastructure.db.entity.ExercisePlanJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExercisePlanMapper {
    ExercisePlan toDomain(ExercisePlanJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    ExercisePlanJpaEntity toJpa(ExercisePlan domain);

    List<ExercisePlan> toDomainList(List<ExercisePlanJpaEntity> jpaEntities);
    List<ExercisePlanJpaEntity> toJpaList(List<ExercisePlan> domainEntities);
}
