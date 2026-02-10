package com.example.liftlogger.application.sync.validators;

import com.example.liftlogger.application.sync.validation.ValidationContext;
import com.example.liftlogger.application.sync.validation.ValidationResult;
import com.example.liftlogger.domain.model.TrainingPlan;
import com.example.liftlogger.domain.outbound.repository.TrainingPlanRepository;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TrainingPlanValidatorTest {

    @Mock
    private TrainingPlanRepository repository;

    @Mock
    private UserRepository userRepository;

    private TrainingPlanValidator validator;
    private ValidationContext context;
    private UUID athleteId;

    @BeforeEach
    void setUp() {
        validator = new TrainingPlanValidator(repository, userRepository);
        athleteId = UUID.randomUUID();
        context = new ValidationContext(athleteId, "ATHLETE");
    }

    @Test
    void validate_validPlan_succeeds() {
        TrainingPlan plan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name("Test Plan")
            .description("Description")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .status("ACTIVE")
            .build();

        when(userRepository.existsById(athleteId)).thenReturn(true);
        when(repository.existsOverlappingPlan(any(), any(), any(), any())).thenReturn(false);

        ValidationResult result = validator.validate(plan, context);

        assertThat(result.isValid()).isTrue();
        assertThat(result.errors()).isEmpty();
    }

    @Test
    void validate_missingName_fails() {
        TrainingPlan plan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name("")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        ValidationResult result = validator.validate(plan, context);

        assertThat(result.isValid()).isFalse();
        assertThat(result.errors())
            .anyMatch(error -> error.field().equals("name"));
    }

    @Test
    void validate_endBeforeStart_fails() {
        TrainingPlan plan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name("Test Plan")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().minusDays(1))
            .build();

        ValidationResult result = validator.validate(plan, context);

        assertThat(result.isValid()).isFalse();
        assertThat(result.errors())
            .anyMatch(error -> error.field().equals("dateRange"));
    }

    @Test
    void validate_overlappingPlan_fails() {
        TrainingPlan plan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(athleteId)
            .name("Test Plan")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        when(userRepository.existsById(athleteId)).thenReturn(true);
        when(repository.existsOverlappingPlan(any(), any(), any(), any())).thenReturn(true);

        ValidationResult result = validator.validate(plan, context);

        assertThat(result.isValid()).isFalse();
        assertThat(result.errors())
            .anyMatch(error -> error.code().equals("CONFLICT"));
    }

    @Test
    void validate_athleteNotFound_fails() {
        TrainingPlan plan = TrainingPlan.builder()
            .id(UUID.randomUUID())
            .athleteId(UUID.randomUUID())
            .name("Test Plan")
            .startDate(LocalDate.now())
            .endDate(LocalDate.now().plusDays(30))
            .build();

        when(userRepository.existsById(any())).thenReturn(false);

        ValidationResult result = validator.validate(plan, context);

        assertThat(result.isValid()).isFalse();
        assertThat(result.errors())
            .anyMatch(error -> error.code().equals("NOT_FOUND"));
    }
}
