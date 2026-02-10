package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.Variant;
import com.example.liftlogger.infrastructure.db.entity.VariantJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface VariantMapper {
    Variant toDomain(VariantJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    VariantJpaEntity toJpa(Variant domain);

    List<Variant> toDomainList(List<VariantJpaEntity> jpaEntities);
    List<VariantJpaEntity> toJpaList(List<Variant> domainEntities);
}
