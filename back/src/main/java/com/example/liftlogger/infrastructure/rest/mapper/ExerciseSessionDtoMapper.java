package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.ExerciseSession;
import com.example.liftlogger.infrastructure.rest.dto.ExerciseSessionDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface ExerciseSessionDtoMapper {
    ExerciseSessionDto toDto(ExerciseSession domain);
    ExerciseSession toDomain(ExerciseSessionDto dto);
    List<ExerciseSessionDto> toDtoList(List<ExerciseSession> domainEntities);
    List<ExerciseSession> toDomainList(List<ExerciseSessionDto> dtos);
}
