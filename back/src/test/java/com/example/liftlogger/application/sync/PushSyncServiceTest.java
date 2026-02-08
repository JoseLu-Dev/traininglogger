package com.example.liftlogger.application.sync;

import com.example.liftlogger.application.sync.dto.PushSyncRequest;
import com.example.liftlogger.application.sync.dto.PushSyncResponse;
import com.example.liftlogger.application.sync.validation.EntityValidator;
import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationError;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.outbound.repository.GenericSyncRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyList;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PushSyncServiceTest {

    @Mock
    private RepositoryProvider repositoryProvider;

    @Mock
    private UserContextProvider userContextProvider;

    @Mock
    private GenericSyncRepository<TrainingPlan> trainingPlanRepository;

    @Mock
    private EntityValidator<TrainingPlan> trainingPlanValidator;

    private EntityRegistry entityRegistry;
    private PushSyncService pushSyncService;
    private ValidationContext validationContext;

    @BeforeEach
    void setUp() {
        entityRegistry = new EntityRegistry();
        entityRegistry.register(TrainingPlan.class, "athleteId", trainingPlanValidator);

        pushSyncService = new PushSyncService(
            entityRegistry,
            repositoryProvider,
            userContextProvider
        );

        validationContext = new ValidationContext(UUID.randomUUID(), "ATHLETE");
        when(userContextProvider.getValidationContext(any()))
            .thenReturn(validationContext);
        when(repositoryProvider.getRepository(TrainingPlan.class))
            .thenReturn(trainingPlanRepository);
    }

    @Test
    void pushEntities_allValid_savesAllEntities() {
        UUID userId = UUID.randomUUID();
        TrainingPlan plan1 = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Plan 1")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        when(trainingPlanValidator.validate(any(), any()))
            .thenReturn(ValidationResult.success());
        when(trainingPlanRepository.saveAll(anyList()))
            .thenReturn(List.of(plan1));

        PushSyncRequest request = new PushSyncRequest(
            Map.of("TrainingPlan", List.of(plan1))
        );
        PushSyncResponse response = pushSyncService.pushEntities(userId, request);

        assertThat(response.successCount()).isEqualTo(1);
        assertThat(response.failureCount()).isZero();
        assertThat(response.failures()).isEmpty();
        assertThat(response.isFullSuccess()).isTrue();

        verify(trainingPlanRepository).saveAll(anyList());
    }

    @Test
    void pushEntities_someInvalid_savesValidReturnsFailures() {
        UUID userId = UUID.randomUUID();
        TrainingPlan validPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("Valid Plan")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        TrainingPlan invalidPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("")  // Invalid: empty name
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().minusDays(1))  // Invalid: end before start
            .build();

        when(trainingPlanValidator.validate(eq(validPlan), any()))
            .thenReturn(ValidationResult.success());
        when(trainingPlanValidator.validate(eq(invalidPlan), any()))
            .thenReturn(ValidationResult.failure(List.of(
                ValidationError.required("name"),
                ValidationError.invalid("endDate", "End date must be after start date")
            )));

        PushSyncRequest request = new PushSyncRequest(
            Map.of("TrainingPlan", List.of(validPlan, invalidPlan))
        );
        PushSyncResponse response = pushSyncService.pushEntities(userId, request);

        assertThat(response.successCount()).isEqualTo(1);
        assertThat(response.failureCount()).isEqualTo(1);
        assertThat(response.failures()).hasSize(1);
        assertThat(response.failures().get(0).entityId()).isEqualTo(invalidPlan.getId());
        assertThat(response.failures().get(0).errors()).hasSize(2);

        verify(trainingPlanRepository).saveAll(argThat(list -> list.size() == 1));
    }

    @Test
    void pushEntities_allInvalid_savesNothingReturnsAllFailures() {
        UUID userId = UUID.randomUUID();
        TrainingPlan invalidPlan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(userId)
            .name("")
            .build();

        when(trainingPlanValidator.validate(any(), any()))
            .thenReturn(ValidationResult.failure(
                ValidationError.required("name")
            ));

        PushSyncRequest request = new PushSyncRequest(
            Map.of("TrainingPlan", List.of(invalidPlan))
        );
        PushSyncResponse response = pushSyncService.pushEntities(userId, request);

        assertThat(response.successCount()).isZero();
        assertThat(response.failureCount()).isEqualTo(1);
        assertThat(response.isFullSuccess()).isFalse();

        verify(trainingPlanRepository, never()).saveAll(anyList());
    }
}
