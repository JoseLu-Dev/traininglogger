package com.example.liftlogger.infrastructure.rest.controller;

import com.example.liftlogger.application.inbound.LoginUserUseCase;
import com.example.liftlogger.application.inbound.RegisterUserUseCase;
import com.example.liftlogger.domain.model.User;
import com.example.liftlogger.infrastructure.rest.dto.AuthResponse;
import com.example.liftlogger.infrastructure.rest.dto.LoginRequest;
import com.example.liftlogger.infrastructure.rest.dto.RegisterRequest;
import com.example.liftlogger.infrastructure.rest.mapper.AuthResponseMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@Tag(name = "Auth", description = "Authentication endpoints")
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final RegisterUserUseCase registerUseCase;
    private final LoginUserUseCase loginUseCase;
    private final AuthResponseMapper responseMapper;

    @Operation(summary = "Register a new user")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "User registered successfully"),
            @ApiResponse(responseCode = "409", description = "Email already in use")
    })
    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@RequestBody @Valid RegisterRequest request) {
        User user = registerUseCase.execute(
                request.email(), request.password(), request.role(), request.coachId());
        return responseMapper.toResponse(user);
    }

    @Operation(summary = "Login and start a session")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Login successful"),
            @ApiResponse(responseCode = "401", description = "Invalid credentials")
    })
    @PostMapping("/login")
    public AuthResponse login(@RequestBody @Valid LoginRequest request) {
        User user = loginUseCase.execute(request.email(), request.password());
        return responseMapper.toResponse(user);
    }

    @Operation(summary = "Logout and invalidate session")
    @ApiResponse(responseCode = "204", description = "Logged out successfully")
    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(HttpServletRequest request) {
        request.getSession().invalidate();
    }
}
