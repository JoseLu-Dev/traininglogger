package com.example.liftlogger.infrastructure.db.adapter;

import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import com.example.liftlogger.infrastructure.db.entity.UserJpaEntity;
import com.example.liftlogger.infrastructure.db.mapper.UserJpaMapper;
import com.example.liftlogger.infrastructure.db.repository.UserJpaRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
@RequiredArgsConstructor
public class UserJpaAdapter implements UserRepository {

    private final UserJpaRepository jpaRepository;
    private final UserJpaMapper mapper;

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public User save(User user) {
        return mapper.toDomain(jpaRepository.save(mapper.toEntity(user)));
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return jpaRepository.findByEmail(email).map(mapper::toDomain);
    }

    @Override
    public boolean existsByEmail(String email) {
        return jpaRepository.existsByEmail(email);
    }

    @Override
    public Optional<User> findById(UUID id) {
        return jpaRepository.findById(id).map(mapper::toDomain);
    }

    @Override
    public boolean existsById(UUID id) {
        return jpaRepository.existsById(id);
    }

    @Override
    public List<UUID> findAthleteIdsByCoachId(UUID coachId) {
        CriteriaBuilder cb = entityManager.getCriteriaBuilder();
        CriteriaQuery<UUID> query = cb.createQuery(UUID.class);
        Root<UserJpaEntity> root = query.from(UserJpaEntity.class);

        query.select(root.get("id"));
        query.where(cb.equal(root.get("coachId"), coachId));

        return entityManager.createQuery(query).getResultList();
    }
}
