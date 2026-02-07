package com.example.liftlogger.infrastructure.config;

import com.example.liftlogger.application.inbound.RegisterUserUseCase;
import com.example.liftlogger.domain.exception.UserAlreadyExistsException;
import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.model.UserRole;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DataSeeder {

    private final RegisterUserUseCase registerUseCase;

    @PostConstruct
    public void seed() {
        try {
            User coach = registerUseCase.execute(
                    "coach@example.com", "password123", UserRole.COACH, null);

            registerUseCase.execute(
                    "athlete1@example.com", "password123", UserRole.ATHLETE, coach.getId());
            registerUseCase.execute(
                    "athlete2@example.com", "password123", UserRole.ATHLETE, coach.getId());
        } catch (UserAlreadyExistsException e) {
            // Already seeded
        }
    }
}
