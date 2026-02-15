package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.ExerciseSessionVariant;
import com.example.liftlogger.infrastructure.rest.dto.ExerciseSessionVariantDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExerciseSessionVariantDtoMapper {
    ExerciseSessionVariantDto toDto(ExerciseSessionVariant domain);
    ExerciseSessionVariant toDomain(ExerciseSessionVariantDto dto);
    List<ExerciseSessionVariantDto> toDtoList(List<ExerciseSessionVariant> domainEntities);
    List<ExerciseSessionVariant> toDomainList(List<ExerciseSessionVariantDto> dtos);
}
