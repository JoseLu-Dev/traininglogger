package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.Exercise;
import com.example.liftlogger.infrastructure.rest.dto.ExerciseDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExerciseDtoMapper {
    ExerciseDto toDto(Exercise domain);
    Exercise toDomain(ExerciseDto dto);
    List<ExerciseDto> toDtoList(List<Exercise> domainEntities);
    List<Exercise> toDomainList(List<ExerciseDto> dtos);
}
