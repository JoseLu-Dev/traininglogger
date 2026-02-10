package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.outbound.repository.TrainingPlanRepository;
import com.example.liftlogger.infrastructure.db.entity.TrainingPlanJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.TrainingPlanMapper;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class TrainingPlanJpaAdapter extends GenericJpaSyncAdapter<TrainingPlan, TrainingPlanJpaEntity>
    implements TrainingPlanRepository {

    private final TrainingPlanMapper mapper;

    @Override
    protected Class<TrainingPlanJpaEntity> getJpaEntityClass() {
        return TrainingPlanJpaEntity.class;
    }

    @Override
    public Class<TrainingPlan> getDomainEntityClass() {
        return TrainingPlan.class;
    }

    @Override
    protected String getOwnerFieldName() {
        return "athleteId";
    }

    @Override
    protected TrainingPlan toDomain(TrainingPlanJpaEntity jpaEntity) {
        return mapper.toDomain(jpaEntity);
    }

    @Override
    protected TrainingPlanJpaEntity toJpa(TrainingPlan domainEntity) {
        return mapper.toJpa(domainEntity);
    }

    @Override
    protected List<TrainingPlan> toDomainList(List<TrainingPlanJpaEntity> jpaEntities) {
        return mapper.toDomainList(jpaEntities);
    }

    @Override
    public boolean existsOverlappingPlan(UUID athleteId, LocalDate startDate, LocalDate endDate, UUID excludePlanId) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> query = cb.createQuery(Long.class);
        Root<TrainingPlanJpaEntity> root = query.from(TrainingPlanJpaEntity.class);

        query.select(cb.count(root));

        Predicate athletePredicate = cb.equal(root.get("athleteId"), athleteId);
        Predicate overlapPredicate = cb.and(
            cb.lessThanOrEqualTo(root.get("startDate"), endDate),
            cb.greaterThanOrEqualTo(root.get("endDate"), startDate)
        );

        if (excludePlanId != null) {
            Predicate excludePredicate = cb.notEqual(root.get("id"), excludePlanId);
            query.where(cb.and(athletePredicate, overlapPredicate, excludePredicate));
        } else {
            query.where(cb.and(athletePredicate, overlapPredicate));
        }

        return entityManager.createQuery(query).getSingleResult() > 0;
    }
}
