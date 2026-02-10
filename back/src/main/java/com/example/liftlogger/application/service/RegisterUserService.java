package com.example.liftlogger.application.service;

import com.example.liftlogger.application.inbound.RegisterUserUseCase;
import com.example.liftlogger.domain.exception.CoachNotFoundException;
import com.example.liftlogger.domain.exception.InvalidRoleAssignmentException;
import com.example.liftlogger.domain.exception.UserAlreadyExistsException;
import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.domain.model.UserRole;
import com.example.liftlogger.domain.outbound.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class RegisterUserService implements RegisterUserUseCase {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public User execute(String email, String rawPassword, UserRole role, UUID coachId) {
        if (userRepository.existsByEmail(email)) {
            throw new UserAlreadyExistsException(email);
        }

        if (role == UserRole.ATHLETE) {
            if (coachId == null) {
                throw new InvalidRoleAssignmentException("Athlete must have coachId");
            }
            if (!userRepository.existsById(coachId)) {
                throw new CoachNotFoundException(coachId);
            }
        }

        User user = User.builder()
                .id(UUID.randomUUID())
                .email(email)
                .passwordHash(passwordEncoder.encode(rawPassword))
                .role(role)
                .coachId(coachId)
                .createdAt(LocalDateTime.now(ZoneOffset.UTC))
                .updatedAt(LocalDateTime.now(ZoneOffset.UTC))
                .version(1)
                .build();

        return userRepository.save(user);
    }
}
