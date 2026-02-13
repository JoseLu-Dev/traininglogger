package com.example.liftlogger.domain.outbound.repository;

import com.example.liftlogger.domain.model.User;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface UserRepository {
    User save(User user);
    Optional<User> findById(UUID id);
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    boolean existsById(UUID id);

    /**
     * Find all athlete IDs that belong to a specific coach
     * @param coachId The coach's user ID
     * @return List of athlete user IDs
     */
    List<UUID> findAthleteIdsByCoachId(UUID coachId);
}
