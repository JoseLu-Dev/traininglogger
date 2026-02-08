package com.example.liftlogger.integration;

import com.example.liftlogger.infrastructure.db.entity.UserJpaEntity;
import com.example.liftlogger.infrastructure.security.CurrentUser;
import com.example.liftlogger.domain.model.UserRole;
import jakarta.persistence.EntityManager;
import org.junit.jupiter.api.AfterEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import tools.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Base class for sync integration tests.
 * Sets up MockMvc, ObjectMapper and EntityManager.
 * Provides a helper to create authenticated CurrentUser instances
 * and persist a matching UserJpaEntity so that UserContextProviderImpl
 * can resolve the user during push sync.
 *
 * NOTE: NOT marked @Transactional at the class level so that data committed
 * in helper methods is visible to async threads inside PullSyncService.
 * Each helper that persists data uses its own transactional method.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public abstract class SyncIntegrationTestBase {

    @Autowired
    protected MockMvc mockMvc;

    @Autowired
    protected ObjectMapper objectMapper;

    @Autowired
    protected EntityManager entityManager;

    @Autowired
    private TestDataCleaner testDataCleaner;

    @AfterEach
    void cleanDatabase() {
        testDataCleaner.deleteAll();
    }

    protected void flushAndClear() {
        entityManager.flush();
        entityManager.clear();
    }

    /**
     * Creates a CurrentUser principal and persists the corresponding UserJpaEntity
     * in the test database so that UserContextProviderImpl can find the user.
     * Runs in its own transaction so the user is committed before async queries.
     */
    protected CurrentUser createTestUser(UUID userId) {
        UserJpaEntity userEntity = new UserJpaEntity(
                userId,
                userId + "@test.com",
                "$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206",
                UserRole.ATHLETE,
                null,
                LocalDateTime.now(),
                LocalDateTime.now(),
                1,
                null
        );
        testDataCleaner.save(userEntity);

        return new CurrentUser(
                userId,
                userId + "@test.com",
                "password",
                "ATHLETE",
                List.of(new SimpleGrantedAuthority("ROLE_ATHLETE"))
        );
    }
}
