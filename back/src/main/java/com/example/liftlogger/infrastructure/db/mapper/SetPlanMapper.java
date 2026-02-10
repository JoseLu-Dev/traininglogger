package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.SetPlan;
import com.example.liftlogger.infrastructure.db.entity.SetPlanJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface SetPlanMapper {
    SetPlan toDomain(SetPlanJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    SetPlanJpaEntity toJpa(SetPlan domain);

    List<SetPlan> toDomainList(List<SetPlanJpaEntity> jpaEntities);
    List<SetPlanJpaEntity> toJpaList(List<SetPlan> domainEntities);
}
