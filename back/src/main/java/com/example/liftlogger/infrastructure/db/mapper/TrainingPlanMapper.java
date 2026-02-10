package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.infrastructure.db.entity.TrainingPlanJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrainingPlanMapper {
    TrainingPlan toDomain(TrainingPlanJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    TrainingPlanJpaEntity toJpa(TrainingPlan domain);

    List<TrainingPlan> toDomainList(List<TrainingPlanJpaEntity> jpaEntities);

    List<TrainingPlanJpaEntity> toJpaList(List<TrainingPlan> domainEntities);
}
