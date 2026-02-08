package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.BodyWeightEntry;
import com.example.liftlogger.infrastructure.db.entity.BodyWeightEntryJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface BodyWeightEntryMapper {
    BodyWeightEntry toDomain(BodyWeightEntryJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    BodyWeightEntryJpaEntity toJpa(BodyWeightEntry domain);

    List<BodyWeightEntry> toDomainList(List<BodyWeightEntryJpaEntity> jpaEntities);
    List<BodyWeightEntryJpaEntity> toJpaList(List<BodyWeightEntry> domainEntities);
}
