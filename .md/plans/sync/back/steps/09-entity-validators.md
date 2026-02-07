# Step 9: Entity Validators

## Objective
Implement business validators for all 10 entity types with field validation, cross-entity validation, and business rules.

## Files to Create

### 1. Training Plan Validator

**File:** `src/main/java/com/liftlogger/application/sync/validators/TrainingPlanValidator.java`

```java
package com.liftlogger.application.sync.validators;

import com.liftlogger.application.sync.validation.*;
import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.domain.repository.UserRepository;
import com.liftlogger.domain.repository.TrainingPlanRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TrainingPlanValidator extends BaseValidator implements EntityValidator<TrainingPlan> {

    private final TrainingPlanRepository repository;
    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(TrainingPlan plan, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(plan.getId(), "id");
        requiredUUID(plan.getAthleteId(), "athleteId");
        requiredString(plan.getName(), "name");
        minLength(plan.getName(), 3, "name");
        maxLength(plan.getName(), 100, "name");
        required(plan.getStartDate(), "startDate");
        required(plan.getEndDate(), "endDate");
        dateRange(plan.getStartDate(), plan.getEndDate(), "dateRange");

        // Status validation
        if (plan.getStatus() != null &&
            !List.of("DRAFT", "ACTIVE", "COMPLETED", "ARCHIVED").contains(plan.getStatus())) {
            errors.add(ValidationError.invalid("status",
                "Status must be one of: DRAFT, ACTIVE, COMPLETED, ARCHIVED"));
        }

        // Ownership validation
        if (!plan.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create training plans for yourself"));
        }

        // Cross-entity validation
        if (plan.getAthleteId() != null && !userRepository.existsById(plan.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        // Business rule: No overlapping plans
        if (plan.getStartDate() != null && plan.getEndDate() != null) {
            boolean hasOverlap = repository.existsOverlappingPlan(
                plan.getAthleteId(),
                plan.getStartDate(),
                plan.getEndDate(),
                plan.getId()
            );
            if (hasOverlap) {
                errors.add(ValidationError.conflict("dateRange",
                    "Another training plan exists in this date range"));
            }
        }

        return buildResult();
    }
}
```

### 2. Set Session Validator

**File:** `src/main/java/com/liftlogger/application/sync/validators/SetSessionValidator.java`

```java
package com.liftlogger.application.sync.validators;

import com.liftlogger.application.sync.validation.*;
import com.liftlogger.domain.entity.SetSession;
import com.liftlogger.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SetSessionValidator extends BaseValidator implements EntityValidator<SetSession> {

    private final UserRepository userRepository;
    private final ExerciseRepository exerciseRepository;
    private final TrainingPlanRepository trainingPlanRepository;

    @Override
    public ValidationResult validate(SetSession session, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(session.getId(), "id");
        requiredUUID(session.getAthleteId(), "athleteId");
        requiredUUID(session.getExerciseId(), "exerciseId");
        required(session.getSessionDate(), "sessionDate");

        // Reps validation
        if (session.getReps() != null) {
            min(session.getReps(), 0, "reps");
            max(session.getReps(), 1000, "reps");
        }

        // Weight validation
        if (session.getWeight() != null) {
            min(session.getWeight(), 0.0, "weight");
            max(session.getWeight(), 1000.0, "weight");
        }

        // Notes length
        maxLength(session.getNotes(), 1000, "notes");

        // Ownership validation
        if (!session.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create set sessions for yourself"));
        }

        // Cross-entity validation
        if (session.getAthleteId() != null && !userRepository.existsById(session.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        if (session.getExerciseId() != null && !exerciseRepository.existsById(session.getExerciseId())) {
            errors.add(ValidationError.notFound("exerciseId", "Exercise"));
        }

        if (session.getTrainingPlanId() != null &&
            !trainingPlanRepository.existsById(session.getTrainingPlanId())) {
            errors.add(ValidationError.notFound("trainingPlanId", "TrainingPlan"));
        }

        return buildResult();
    }
}
```

### 3. Exercise Validator

**File:** `src/main/java/com/liftlogger/application/sync/validators/ExerciseValidator.java`

```java
package com.liftlogger.application.sync.validators;

import com.liftlogger.application.sync.validation.*;
import com.liftlogger.domain.entity.Exercise;
import com.liftlogger.domain.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ExerciseValidator extends BaseValidator implements EntityValidator<Exercise> {

    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(Exercise exercise, ValidationContext context) {
        clearErrors();

        // Field validation
        requiredUUID(exercise.getId(), "id");
        requiredUUID(exercise.getCoachId(), "coachId");
        requiredString(exercise.getName(), "name");
        minLength(exercise.getName(), 3, "name");
        maxLength(exercise.getName(), 100, "name");
        maxLength(exercise.getDescription(), 2000, "description");

        // Ownership validation (only coaches can create exercises)
        if (!context.isCoach()) {
            errors.add(ValidationError.invalid("coachId",
                "Only coaches can create exercises"));
        }

        if (!exercise.getCoachId().equals(context.currentUserId())) {
            errors.add(ValidationError.invalid("coachId",
                "You can only create exercises for yourself"));
        }

        // Cross-entity validation
        if (exercise.getCoachId() != null && !userRepository.existsById(exercise.getCoachId())) {
            errors.add(ValidationError.notFound("coachId", "User"));
        }

        return buildResult();
    }
}
```

### 4. Simple Entity Validators

For entities without complex business rules, create simple validators:

**File:** `src/main/java/com/liftlogger/application/sync/validators/BodyWeightEntryValidator.java`

```java
package com.liftlogger.application.sync.validators;

import com.liftlogger.application.sync.validation.*;
import com.liftlogger.domain.entity.BodyWeightEntry;
import com.liftlogger.domain.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BodyWeightEntryValidator extends BaseValidator
    implements EntityValidator<BodyWeightEntry> {

    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(BodyWeightEntry entry, ValidationContext context) {
        clearErrors();

        requiredUUID(entry.getId(), "id");
        requiredUUID(entry.getAthleteId(), "athleteId");
        required(entry.getDate(), "date");

        // Weight validation
        if (entry.getWeight() != null) {
            min(entry.getWeight(), 20.0, "weight");
            max(entry.getWeight(), 500.0, "weight");
        }

        // Ownership validation
        if (!entry.getAthleteId().equals(context.currentUserId()) && !context.isCoach()) {
            errors.add(ValidationError.invalid("athleteId",
                "You can only create body weight entries for yourself"));
        }

        // Cross-entity validation
        if (!userRepository.existsById(entry.getAthleteId())) {
            errors.add(ValidationError.notFound("athleteId", "User"));
        }

        return buildResult();
    }
}
```

### 5. Additional Validators Needed

Create validators for the remaining entities following the same patterns:

**Validators to implement:**
- `UserValidator` - for User entity
- `VariantValidator` - for exercise variants
- `ExercisePlanValidator` - for planned exercises
- `SetPlanValidator` - for planned sets
- `TrainingSessionValidator` - for training sessions
- `ExerciseSessionValidator` - for exercise sessions

Example structure (similar to above validators):

```java
@Component
@RequiredArgsConstructor
public class VariantValidator extends BaseValidator
    implements EntityValidator<Variant> {

    private final UserRepository userRepository;

    @Override
    public ValidationResult validate(Variant variant, ValidationContext context) {
        clearErrors();

        requiredUUID(variant.getId(), "id");
        requiredUUID(variant.getCoachId(), "coachId");
        requiredString(variant.getName(), "name");
        minLength(variant.getName(), 2, "name");
        maxLength(variant.getName(), 100, "name");
        maxLength(variant.getDescription(), 1000, "description");

        // Ownership validation (only coaches can create variants)
        if (!context.isCoach()) {
            errors.add(ValidationError.invalid("coachId",
                "Only coaches can create variants"));
        }

        if (!variant.getCoachId().equals(context.currentUserId())) {
            errors.add(ValidationError.invalid("coachId",
                "You can only create variants for yourself"));
        }

        // Cross-entity validation
        if (!userRepository.existsById(variant.getCoachId())) {
            errors.add(ValidationError.notFound("coachId", "User"));
        }

        return buildResult();
    }
}
```

### 6. Update Entity Registry Configuration

**File:** `src/main/java/com/liftlogger/application/sync/EntitySyncConfiguration.java` (update)

```java
@Configuration
public class EntitySyncConfiguration {

    // Inject all validators
    @Autowired private UserValidator userValidator;
    @Autowired private ExerciseValidator exerciseValidator;
    @Autowired private VariantValidator variantValidator;
    @Autowired private TrainingPlanValidator trainingPlanValidator;
    @Autowired private ExercisePlanValidator exercisePlanValidator;
    @Autowired private SetPlanValidator setPlanValidator;
    @Autowired private TrainingSessionValidator trainingSessionValidator;
    @Autowired private ExerciseSessionValidator exerciseSessionValidator;
    @Autowired private SetSessionValidator setSessionValidator;
    @Autowired private BodyWeightEntryValidator bodyWeightEntryValidator;

    @Bean
    public EntityRegistry entityRegistry() {
        EntityRegistry registry = new EntityRegistry();

        // Register all 10 entities with their validators
        registry.register(User.class, "id", userValidator);
        registry.register(Exercise.class, "coachId", exerciseValidator);
        registry.register(Variant.class, "coachId", variantValidator);
        registry.register(TrainingPlan.class, "athleteId", trainingPlanValidator);
        registry.register(ExercisePlan.class, "athleteId", exercisePlanValidator);
        registry.register(SetPlan.class, "athleteId", setPlanValidator);
        registry.register(TrainingSession.class, "athleteId", trainingSessionValidator);
        registry.register(ExerciseSession.class, "athleteId", exerciseSessionValidator);
        registry.register(SetSession.class, "athleteId", setSessionValidator);
        registry.register(BodyWeightEntry.class, "athleteId", bodyWeightEntryValidator);

        return registry;
    }
}
```

## Testing

**File:** `src/test/java/com/liftlogger/application/sync/validators/TrainingPlanValidatorTest.java`

```java
package com.liftlogger.application.sync.validators;

import com.liftlogger.application.sync.validation.ValidationContext;
import com.liftlogger.application.sync.validation.ValidationResult;
import com.liftlogger.domain.entity.TrainingPlan;
import com.liftlogger.domain.repository.UserRepository;
import com.liftlogger.domain.repository.TrainingPlanRepository;
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
            .name("")  // Invalid: empty name
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
            .endDate(LocalDate.now().minusDays(1))  // Invalid: end before start
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
```

## Validator Checklist

Create validators for all 10 entities:

1. ✅ `TrainingPlanValidator`
2. ✅ `SetSessionValidator`
3. ✅ `ExerciseValidator`
4. `UserValidator`
5. `VariantValidator`
6. `ExercisePlanValidator`
7. `SetPlanValidator`
8. `TrainingSessionValidator`
9. `ExerciseSessionValidator`
10. ✅ `BodyWeightEntryValidator`

## Acceptance Criteria

- ✅ All 10 validators implement `EntityValidator<T>`
- ✅ Field validation (required, length, min/max)
- ✅ Cross-entity validation (foreign keys exist)
- ✅ Business rules (overlapping dates, ownership, etc.)
- ✅ Ownership validation (user can only modify their own data)
- ✅ Role-based validation (coaches vs athletes)
- ✅ Clear error messages with field, code, and message
- ✅ Tests pass for all validators
- ✅ Entity registry configured with all validators

## Next Step

After completing this step, move to **10-testing.md** to write comprehensive integration tests.
