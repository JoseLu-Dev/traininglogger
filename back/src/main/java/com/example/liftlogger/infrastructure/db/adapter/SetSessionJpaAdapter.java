package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.SetSession;
import com.example.liftlogger.domain.outbound.repository.SetSessionRepository;
import com.example.liftlogger.infrastructure.db.entity.SetSessionJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.SetSessionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class SetSessionJpaAdapter extends GenericJpaSyncAdapter<SetSession, SetSessionJpaEntity>
    implements SetSessionRepository {

    private final SetSessionMapper mapper;

    @Override
    protected Class<SetSessionJpaEntity> getJpaEntityClass() {
        return SetSessionJpaEntity.class;
    }

    @Override
    public Class<SetSession> getDomainEntityClass() {
        return SetSession.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected SetSession toDomain(SetSessionJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected SetSessionJpaEntity toJpa(SetSession domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<SetSession> toDomainList(List<SetSessionJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }
}
