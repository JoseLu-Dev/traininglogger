package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Generic JPA adapter that implements sync repository operations using Criteria API.
 * This adapter is extended by entity-specific adapters.
 *
 * @param <D> Domain entity type
 * @param <J> JPA entity type
 */
public abstract class GenericJpaSyncAdapter<D, J> implements GenericSyncRepository<D> {

    @PersistenceContext
    protected EntityManager entityManager;

    protected abstract Class<J> getJpaEntityClass();

    public abstract Class<D> getDomainEntityClass();

    protected abstract String getOwnerFieldName();

    protected abstract D toDomain(J jpaEntity);

    protected abstract J toJpa(D domainEntity);

    protected abstract List<D> toDomainList(List<J> jpaEntities);

    @Override
    public List<D> findByOwnerAndUpdatedAfter(UUID ownerId, Instant lastSyncTime) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
        Root<J> root = query.from(getJpaEntityClass());

        Predicate ownerPredicate = cb.equal(root.get(getOwnerFieldName()), ownerId);
        Predicate updatedPredicate = cb.greaterThan(root.get("updatedAt"), lastSyncTime);

        query.where(cb.and(ownerPredicate, updatedPredicate));
        query.orderBy(cb.asc(root.get("updatedAt")));

        List<J> results = entityManager.createQuery(query).getResultList();
        return toDomainList(results);
    }

    @Override
    public List<D> findByOwner(UUID ownerId) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
        Root<J> root = query.from(getJpaEntityClass());

        query.where(cb.equal(root.get(getOwnerFieldName()), ownerId));
        query.orderBy(cb.asc(root.get("createdAt")));

        List<J> results = entityManager.createQuery(query).getResultList();
        return toDomainList(results);
    }

    @Override
    public D save(D entity) {
        J jpaEntity = toJpa(entity);
        J savedEntity = entityManager.merge(jpaEntity);
        entityManager.flush();
        return toDomain(savedEntity);
    }

    @Override
    public List<D> saveAll(List<D> entities) {
        List<J> jpaEntities = entities.stream()
            .map(this::toJpa)
            .toList();

        for (int i = 0; i < jpaEntities.size(); i++) {
            entityManager.merge(jpaEntities.get(i));

            // Flush and clear every 50 entities for performance
            if (i % 50 == 0) {
                entityManager.flush();
                entityManager.clear();
            }
        }
        entityManager.flush();

        return entities;
    }

    @Override
    public boolean existsById(UUID id) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<Long> query = cb.createQuery(Long.class);
        Root<J> root = query.from(getJpaEntityClass());

        query.select(cb.count(root));
        query.where(cb.equal(root.get("id"), id));

        return entityManager.createQuery(query).getSingleResult() > 0;
    }

    @Override
    public D findById(UUID id) {
        J jpaEntity = entityManager.find(getJpaEntityClass(), id);
        return jpaEntity != null ? toDomain(jpaEntity) : null;
    }

    @Override
    public List<D> findByOwners(List<UUID> ownerIds) {
        if (ownerIds == null || ownerIds.isEmpty()) {
            return List.of();
        }

        // Single owner optimization
        if (ownerIds.size() == 1) {
            return findByOwner(ownerIds.get(0));
        }

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
        Root<J> root = query.from(getJpaEntityClass());

        query.where(root.get(getOwnerFieldName()).in(ownerIds));
        query.orderBy(cb.asc(root.get("createdAt")));

        List<J> results = entityManager.createQuery(query).getResultList();
        return toDomainList(results);
    }

    @Override
    public List<D> findByOwnersAndUpdatedAfter(List<UUID> ownerIds, Instant lastSyncTime) {
        if (ownerIds == null || ownerIds.isEmpty()) {
            return List.of();
        }

        // Single owner optimization
        if (ownerIds.size() == 1) {
            return findByOwnerAndUpdatedAfter(ownerIds.get(0), lastSyncTime);
        }

        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<J> query = cb.createQuery(getJpaEntityClass());
        Root<J> root = query.from(getJpaEntityClass());

        Predicate ownerPredicate = root.get(getOwnerFieldName()).in(ownerIds);
        Predicate updatedPredicate = cb.greaterThan(root.get("updatedAt"), lastSyncTime);

        query.where(cb.and(ownerPredicate, updatedPredicate));
        query.orderBy(cb.asc(root.get("updatedAt")));

        List<J> results = entityManager.createQuery(query).getResultList();
        return toDomainList(results);
    }
}
