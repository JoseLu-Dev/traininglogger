package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.infrastructure.rest.dto.SetSessionDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface SetSessionDtoMapper {
    SetSessionDto toDto(SetSession domain);
    SetSession toDomain(SetSessionDto dto);
    List<SetSessionDto> toDtoList(List<SetSession> domainEntities);
    List<SetSession> toDomainList(List<SetSessionDto> dtos);
}
