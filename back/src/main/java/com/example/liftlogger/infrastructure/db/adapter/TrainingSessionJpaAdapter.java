package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.TrainingSession;
import com.example.liftlogger.domain.outbound.repository.TrainingSessionRepository;
import com.example.liftlogger.infrastructure.db.entity.TrainingSessionJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.TrainingSessionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class TrainingSessionJpaAdapter extends GenericJpaSyncAdapter<TrainingSession, TrainingSessionJpaEntity>
    implements TrainingSessionRepository {

    private final TrainingSessionMapper mapper;

    @Override
    protected Class<TrainingSessionJpaEntity> getJpaEntityClass() {
        return TrainingSessionJpaEntity.class;
    }

    @Override
    public Class<TrainingSession> getDomainEntityClass() {
        return TrainingSession.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected TrainingSession toDomain(TrainingSessionJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected TrainingSessionJpaEntity toJpa(TrainingSession domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<TrainingSession> toDomainList(List<TrainingSessionJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
