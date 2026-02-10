package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.ExercisePlan;
import com.example.liftlogger.infrastructure.rest.dto.ExercisePlanDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExercisePlanDtoMapper {
    ExercisePlanDto toDto(ExercisePlan domain);
    ExercisePlan toDomain(ExercisePlanDto dto);
    List<ExercisePlanDto> toDtoList(List<ExercisePlan> domainEntities);
    List<ExercisePlan> toDomainList(List<ExercisePlanDto> dtos);
}
