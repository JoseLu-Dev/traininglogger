package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.TrainingSession;
import com.example.liftlogger.infrastructure.rest.dto.TrainingSessionDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrainingSessionDtoMapper {
    TrainingSessionDto toDto(TrainingSession domain);
    TrainingSession toDomain(TrainingSessionDto dto);
    List<TrainingSessionDto> toDtoList(List<TrainingSession> domainEntities);
    List<TrainingSession> toDomainList(List<TrainingSessionDto> dtos);
}
