package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.BodyWeightEntry;
import com.example.liftlogger.infrastructure.rest.dto.BodyWeightEntryDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface BodyWeightEntryDtoMapper {
    BodyWeightEntryDto toDto(BodyWeightEntry domain);
    BodyWeightEntry toDomain(BodyWeightEntryDto dto);
    List<BodyWeightEntryDto> toDtoList(List<BodyWeightEntry> domainEntities);
    List<BodyWeightEntry> toDomainList(List<BodyWeightEntryDto> dtos);
}
