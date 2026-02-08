package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.infrastructure.db.entity.SetSessionJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface SetSessionMapper {
    SetSession toDomain(SetSessionJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    SetSessionJpaEntity toJpa(SetSession domain);

    List<SetSession> toDomainList(List<SetSessionJpaEntity> jpaEntities);
    List<SetSessionJpaEntity> toJpaList(List<SetSession> domainEntities);
}
