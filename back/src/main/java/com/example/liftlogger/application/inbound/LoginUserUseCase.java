package com.example.liftlogger.application.inbound;

import com.example.liftlogger.domain.model.User;

public interface LoginUserUseCase {
    User execute(String email, String rawPassword);
}
