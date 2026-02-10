package com.example.liftlogger.infrastructure.db.mapper;

import com.example.liftlogger.domain.model.TrainingSession;
import com.example.liftlogger.infrastructure.db.entity.TrainingSessionJpaEntity;
import org.mapstruct.BeanMapping;
import org.mapstruct.Builder;
import org.mapstruct.Mapper;

import java.util.List;

@Mapper(componentModel = "spring")
public interface TrainingSessionMapper {
    TrainingSession toDomain(TrainingSessionJpaEntity jpaEntity);

    @BeanMapping(builder = @Builder(disableBuilder = true))
    TrainingSessionJpaEntity toJpa(TrainingSession domain);

    List<TrainingSession> toDomainList(List<TrainingSessionJpaEntity> jpaEntities);
    List<TrainingSessionJpaEntity> toJpaList(List<TrainingSession> domainEntities);
}
