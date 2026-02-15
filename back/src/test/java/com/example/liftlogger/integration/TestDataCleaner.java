package com.example.liftlogger.integration;

import jakarta.persistence.EntityManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/**
 * Helper component for integration tests.
 * Provides transactional save and cleanup methods so that persisted data
 * is committed to the in-memory database before async threads query it.
 */
@Component
public class TestDataCleaner {

    @Autowired
    private EntityManager entityManager;

    @Transactional
    public void save(Object entity) {
        entityManager.persist(entity);
        entityManager.flush();
    }

    @Transactional
    public <T> T saveAndReturn(T entity) {
        entityManager.persist(entity);
        entityManager.flush();
        return entity;
    }

    /**
     * Updates the updatedAt timestamp of an entity by ID, bypassing @PreUpdate.
     * Used in tests to set specific timestamps for incremental sync testing.
     */
    @Transactional
    public void forceUpdatedAt(Class<?> entityClass, java.util.UUID id, java.time.Instant updatedAt) {
        String jpql = "UPDATE " + entityClass.getSimpleName() + " e SET e.updatedAt = :updatedAt WHERE e.id = :id";
        entityManager.createQuery(jpql)
                .setParameter("updatedAt", updatedAt)
                .setParameter("id", id)
                .executeUpdate();
        entityManager.flush();
    }

    @Transactional
    public void deleteAll() {
        entityManager.createQuery("DELETE FROM SetSessionJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM ExerciseSessionJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM TrainingSessionJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM SetPlanJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM ExercisePlanJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM TrainingPlanJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM BodyWeightEntryJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM VariantJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM ExerciseJpaEntity").executeUpdate();
        entityManager.createQuery("DELETE FROM UserJpaEntity").executeUpdate();
        entityManager.flush();
    }
}
