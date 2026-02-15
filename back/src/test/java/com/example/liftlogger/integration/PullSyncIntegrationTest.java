package com.example.liftlogger.integration;

import com.example.liftlogger.infrastructure.db.entity.TrainingPlanJpaEntity;
import com.example.liftlogger.infrastructure.rest.dto.sync.PullSyncRequestDto;
import com.example.liftlogger.infrastructure.security.CurrentUser;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.is;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.user;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class PullSyncIntegrationTest extends SyncIntegrationTestBase {

    @Autowired
    private TestDataCleaner testDataCleaner;

    @Test
    void pullSync_fullSync_returnsAllEntities() throws Exception {
        UUID userId = UUID.randomUUID();
        CurrentUser currentUser = createTestUser(userId);

        testDataCleaner.save(createTrainingPlan(userId, "Plan 1"));
        testDataCleaner.save(createTrainingPlan(userId, "Plan 2"));

        PullSyncRequestDto request = new PullSyncRequestDto(
                List.of("TrainingPlan"),
                null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(currentUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalEntities", is(2)))
                .andExpect(jsonPath("$.syncTimestamp").exists())
                .andExpect(jsonPath("$.entities.TrainingPlan", hasSize(2)))
                .andExpect(jsonPath("$.entities.TrainingPlan[0].name").exists());
    }

    @Test
    void pullSync_incrementalSync_returnsOnlyRecentEntities() throws Exception {
        UUID userId = UUID.randomUUID();
        CurrentUser currentUser = createTestUser(userId);

        Instant twoHoursAgo = Instant.now().minusSeconds(7200);
        Instant oneHourAgo = Instant.now().minusSeconds(3600);

        TrainingPlanJpaEntity oldPlan = createTrainingPlan(userId, "Old Plan");
        TrainingPlanJpaEntity newPlan = createTrainingPlan(userId, "New Plan");

        testDataCleaner.save(oldPlan);
        testDataCleaner.save(newPlan);

        // Force the timestamps after persist (bypasses @PrePersist/@PreUpdate)
        testDataCleaner.forceUpdatedAt(TrainingPlanJpaEntity.class, oldPlan.getId(), twoHoursAgo);
        testDataCleaner.forceUpdatedAt(TrainingPlanJpaEntity.class, newPlan.getId(), Instant.now());

        PullSyncRequestDto request = new PullSyncRequestDto(
                List.of("TrainingPlan"),
                oneHourAgo
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(currentUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalEntities", is(1)))
                .andExpect(jsonPath("$.entities.TrainingPlan[0].name", is("New Plan")));
    }

    @Test
    void pullSync_noData_returnsEmptyResponse() throws Exception {
        UUID userId = UUID.randomUUID();
        CurrentUser currentUser = createTestUser(userId);

        PullSyncRequestDto request = new PullSyncRequestDto(
                List.of("TrainingPlan"),
                null
        );

        mockMvc.perform(post("/api/v1/sync/pull")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request))
                        .with(user(currentUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.totalEntities", is(0)));
    }

    private TrainingPlanJpaEntity createTrainingPlan(UUID athleteId, String name) {
        TrainingPlanJpaEntity plan = TrainingPlanJpaEntity.builder()
                .athleteId(athleteId)
                .name(name)
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(30))
                .status("ACTIVE")
                .build();
        plan.setId(UUID.randomUUID());
        plan.setCreatedAt(Instant.now());
        plan.setUpdatedAt(Instant.now());
        return plan;
    }
}
