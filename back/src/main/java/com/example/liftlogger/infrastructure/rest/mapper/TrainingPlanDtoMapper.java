package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.infrastructure.rest.dto.TrainingPlanDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrainingPlanDtoMapper {
    TrainingPlanDto toDto(TrainingPlan domain);
    TrainingPlan toDomain(TrainingPlanDto dto);
    List<TrainingPlanDto> toDtoList(List<TrainingPlan> domainEntities);
    List<TrainingPlan> toDomainList(List<TrainingPlanDto> dtos);
}
