package com.example.liftlogger.application.sync.validation;

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
