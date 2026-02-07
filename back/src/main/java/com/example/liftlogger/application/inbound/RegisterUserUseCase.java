package com.example.liftlogger.application.inbound;

import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.model.UserRole;

import java.util.UUID;

public interface RegisterUserUseCase {
    User execute(String email, String rawPassword, UserRole role, UUID coachId);
}
