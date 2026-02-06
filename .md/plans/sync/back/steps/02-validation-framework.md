# Step 2: Validation Framework

## Objective
Create the validation framework that will be used by the push sync to validate entities before saving.

## Files to Create

### 1. Validation Result Types

**File:** `src/main/java/com/liftlogger/application/sync/validation/ValidationResult.java`

```java
package com.liftlogger.application.sync.validation;

import java.util.List;

public record ValidationResult(
    boolean isValid,
    List<ValidationError> errors
) {
    public static ValidationResult success() {
        return new ValidationResult(true, List.of());
    }

    public static ValidationResult failure(List<ValidationError> errors) {
        return new ValidationResult(false, errors);
    }

    public static ValidationResult failure(ValidationError error) {
        return new ValidationResult(false, List.of(error));
    }
}
```

**File:** `src/main/java/com/liftlogger/application/sync/validation/ValidationError.java`

```java
package com.liftlogger.application.sync.validation;

public record ValidationError(
    String field,
    String code,
    String message
) {
    public static ValidationError required(String field) {
        return new ValidationError(field, "REQUIRED", field + " is required");
    }

    public static ValidationError invalid(String field, String message) {
        return new ValidationError(field, "INVALID", message);
    }

    public static ValidationError notFound(String field, String entityType) {
        return new ValidationError(field, "NOT_FOUND", entityType + " not found");
    }

    public static ValidationError conflict(String field, String message) {
        return new ValidationError(field, "CONFLICT", message);
    }
}
```

**File:** `src/main/java/com/liftlogger/application/sync/validation/ValidationContext.java`

```java
package com.liftlogger.application.sync.validation;

import java.util.UUID;

/**
 * Context passed to validators containing user information
 */
public record ValidationContext(
    UUID currentUserId,
    String currentUserRole  // ATHLETE, COACH, ADMIN
) {
    public boolean isCoach() {
        return "COACH".equals(currentUserRole);
    }

    public boolean isAthlete() {
        return "ATHLETE".equals(currentUserRole);
    }

    public boolean isAdmin() {
        return "ADMIN".equals(currentUserRole);
    }
}
```

### 2. Entity Validator Interface

**File:** `src/main/java/com/liftlogger/application/sync/validation/EntityValidator.java`

```java
package com.liftlogger.application.sync.validation;

/**
 * Generic validator interface for entity validation.
 * Each entity type has its own validator implementation.
 *
 * @param <T> The domain entity type
 */
public interface EntityValidator<T> {

    /**
     * Validate an entity with business rules
     *
     * @param entity The entity to validate
     * @param context User context for validation
     * @return ValidationResult with errors if validation fails
     */
    ValidationResult validate(T entity, ValidationContext context);
}
```

### 3. Base Validator (Optional Helper)

**File:** `src/main/java/com/liftlogger/application/sync/validation/BaseValidator.java`

```java
package com.liftlogger.application.sync.validation;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * Base class with common validation helpers
 */
public abstract class BaseValidator {

    protected List<ValidationError> errors = new ArrayList<>();

    protected void required(Object value, String field) {
        if (value == null) {
            errors.add(ValidationError.required(field));
        }
    }

    protected void requiredString(String value, String field) {
        if (value == null || value.isBlank()) {
            errors.add(ValidationError.required(field));
        }
    }

    protected void requiredUUID(UUID value, String field) {
        if (value == null) {
            errors.add(ValidationError.required(field));
        }
    }

    protected void minLength(String value, int min, String field) {
        if (value != null && value.length() < min) {
            errors.add(ValidationError.invalid(field,
                field + " must be at least " + min + " characters"));
        }
    }

    protected void maxLength(String value, int max, String field) {
        if (value != null && value.length() > max) {
            errors.add(ValidationError.invalid(field,
                field + " must be at most " + max + " characters"));
        }
    }

    protected void min(Number value, Number min, String field) {
        if (value != null && value.doubleValue() < min.doubleValue()) {
            errors.add(ValidationError.invalid(field,
                field + " must be at least " + min));
        }
    }

    protected void max(Number value, Number max, String field) {
        if (value != null && value.doubleValue() > max.doubleValue()) {
            errors.add(ValidationError.invalid(field,
                field + " must be at most " + max));
        }
    }

    protected void dateRange(LocalDate start, LocalDate end, String field) {
        if (start != null && end != null && start.isAfter(end)) {
            errors.add(ValidationError.invalid(field,
                "Start date must be before end date"));
        }
    }

    protected void dateTimeRange(LocalDateTime start, LocalDateTime end, String field) {
        if (start != null && end != null && start.isAfter(end)) {
            errors.add(ValidationError.invalid(field,
                "Start date/time must be before end date/time"));
        }
    }

    protected ValidationResult buildResult() {
        if (errors.isEmpty()) {
            return ValidationResult.success();
        }
        return ValidationResult.failure(errors);
    }

    protected void clearErrors() {
        errors.clear();
    }
}
```

### 4. No-Op Validator (For entities without validation)

**File:** `src/main/java/com/liftlogger/application/sync/validation/NoOpValidator.java`

```java
package com.liftlogger.application.sync.validation;

import org.springframework.stereotype.Component;

/**
 * Validator that always returns success.
 * Use for entities that don't need custom validation.
 */
@Component
public class NoOpValidator<T> implements EntityValidator<T> {

    @Override
    public ValidationResult validate(T entity, ValidationContext context) {
        return ValidationResult.success();
    }
}
```

## Testing

Create a simple test to verify the validation framework:

**File:** `src/test/java/com/liftlogger/application/sync/validation/ValidationFrameworkTest.java`

```java
package com.liftlogger.application.sync.validation;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

class ValidationFrameworkTest {

    @Test
    void validationResult_success() {
        ValidationResult result = ValidationResult.success();

        assertThat(result.isValid()).isTrue();
        assertThat(result.errors()).isEmpty();
    }

    @Test
    void validationResult_failure() {
        ValidationError error = ValidationError.required("name");
        ValidationResult result = ValidationResult.failure(error);

        assertThat(result.isValid()).isFalse();
        assertThat(result.errors()).hasSize(1);
        assertThat(result.errors().get(0).field()).isEqualTo("name");
        assertThat(result.errors().get(0).code()).isEqualTo("REQUIRED");
    }

    @Test
    void validationContext_roleChecks() {
        ValidationContext athleteCtx = new ValidationContext(UUID.randomUUID(), "ATHLETE");
        ValidationContext coachCtx = new ValidationContext(UUID.randomUUID(), "COACH");

        assertThat(athleteCtx.isAthlete()).isTrue();
        assertThat(athleteCtx.isCoach()).isFalse();

        assertThat(coachCtx.isCoach()).isTrue();
        assertThat(coachCtx.isAthlete()).isFalse();
    }

    @Test
    void noOpValidator_alwaysSucceeds() {
        NoOpValidator<String> validator = new NoOpValidator<>();
        ValidationContext ctx = new ValidationContext(UUID.randomUUID(), "ATHLETE");

        ValidationResult result = validator.validate("anything", ctx);

        assertThat(result.isValid()).isTrue();
    }
}
```

## Acceptance Criteria

- ✅ `ValidationResult` record with success/failure factory methods
- ✅ `ValidationError` record with helper factory methods
- ✅ `ValidationContext` record with role checks
- ✅ `EntityValidator<T>` interface with validate method
- ✅ `BaseValidator` helper class with common validations
- ✅ `NoOpValidator` for entities without validation
- ✅ Tests pass for validation framework

## Next Step

After completing this step, move to **03-entity-registry.md** to create the metadata registry.
