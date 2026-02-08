package com.example.liftlogger.infrastructure.rest.mapper;

import com.example.liftlogger.domain.model.Variant;
import com.example.liftlogger.infrastructure.rest.dto.VariantDto;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface VariantDtoMapper {
    VariantDto toDto(Variant domain);
    Variant toDomain(VariantDto dto);
    List<VariantDto> toDtoList(List<Variant> domainEntities);
    List<Variant> toDomainList(List<VariantDto> dtos);
}
