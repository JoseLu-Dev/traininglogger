package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.PullSyncRequest;
import com.example.liftlogger.application.sync.dto.PullSyncResponse;
import com.example.liftlogger.application.sync.validation.NoOpValidator;
import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PullSyncServiceTest {

    @Mock
    private RepositoryProvider repositoryProvider;

    @Mock
    private GenericSyncRepository<TrainingPlan> trainingPlanRepository;

    private EntityRegistry entityRegistry;
    private PullSyncService pullSyncService;

    @BeforeEach
    void setUp() {
        entityRegistry = new EntityRegistry();
        entityRegistry.register(TrainingPlan.class, "athleteId", new NoOpValidator<>());

        pullSyncService = new PullSyncService(entityRegistry, repositoryProvider);
    }

    @Test
    void pullEntities_fullSync_returnsAllEntities() {
        UUID userId = UUID.randomUUID();
        TrainingPlan plan1 = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Plan 1")
            .build();
        TrainingPlan plan2 = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Plan 2")
            .build();

        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
        when(trainingPlanRepository.findByOwner(userId))
            .thenReturn(List.of(plan1, plan2));

        PullSyncRequest request = new PullSyncRequest(List.of("TrainingPlan"), null);
        PullSyncResponse response = pullSyncService.pullEntities(userId, request);

        assertThat(response.totalEntities()).isEqualTo(2);
        assertThat(response.entities()).containsKey("TrainingPlan");
        assertThat(response.entities().get("TrainingPlan")).hasSize(2);
        assertThat(response.syncTimestamp()).isNotNull();
    }

    @Test
    void pullEntities_incrementalSync_returnsOnlyUpdatedEntities() {
        UUID userId = UUID.randomUUID();
        Instant lastSyncTime = Instant.now().minusSeconds(3600);

        TrainingPlan recentPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Recent Plan")
            .updatedAt(Instant.now())
            .build();

        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
        when(trainingPlanRepository.findByOwnerAndUpdatedAfter(eq(userId), any()))
            .thenReturn(List.of(recentPlan));

        PullSyncRequest request = new PullSyncRequest(
            List.of("TrainingPlan"),
            lastSyncTime
        );
        PullSyncResponse response = pullSyncService.pullEntities(userId, request);

        assertThat(response.totalEntities()).isEqualTo(1);
        assertThat(response.entities().get("TrainingPlan")).hasSize(1);
    }

    @Test
    void pullEntities_noEntities_returnsEmptyResponse() {
        UUID userId = UUID.randomUUID();

        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
        when(trainingPlanRepository.findByOwner(userId))
            .thenReturn(List.of());

        PullSyncRequest request = new PullSyncRequest(List.of("TrainingPlan"), null);
        PullSyncResponse response = pullSyncService.pullEntities(userId, request);

        assertThat(response.totalEntities()).isZero();
        assertThat(response.entities()).isEmpty();
    }
}
