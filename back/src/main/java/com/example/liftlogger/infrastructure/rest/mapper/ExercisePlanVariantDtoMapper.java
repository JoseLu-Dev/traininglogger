package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.ExercisePlanVariant;
import com.example.liftlogger.infrastructure.rest.dto.ExercisePlanVariantDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExercisePlanVariantDtoMapper {
    ExercisePlanVariantDto toDto(ExercisePlanVariant domain);
    ExercisePlanVariant toDomain(ExercisePlanVariantDto dto);
    List<ExercisePlanVariantDto> toDtoList(List<ExercisePlanVariant> domainEntities);
    List<ExercisePlanVariant> toDomainList(List<ExercisePlanVariantDto> dtos);
}
