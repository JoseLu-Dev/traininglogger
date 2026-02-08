package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.SetPlan;
import com.example.liftlogger.infrastructure.rest.dto.SetPlanDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface SetPlanDtoMapper {
    SetPlanDto toDto(SetPlan domain);
    SetPlan toDomain(SetPlanDto dto);
    List<SetPlanDto> toDtoList(List<SetPlan> domainEntities);
    List<SetPlan> toDomainList(List<SetPlanDto> dtos);
}
