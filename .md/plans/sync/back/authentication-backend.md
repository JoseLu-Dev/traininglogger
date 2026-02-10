# Backend Authentication - LiftLogger

## Context

Implement JWT-free, session-based authentication for offline-first training app. Two roles: COACH (manages athletes) & ATHLETE (self-data only). Spring Boot 4.0.2 + Spring Security + JDBC sessions. Hexagonal architecture (domain → application → infrastructure). Client handles offline password validation separately.

## Requirements

- Single User entity: email login, BCrypt hash, ROLE_COACH/ROLE_ATHLETE, one-to-many coach-athlete
- Endpoints: POST /api/auth/register, /login, /logout
- 30-day JDBC sessions, public registration, athletes provide coachId
- Sync metadata: id, createdAt, updatedAt, version, deletedAt (soft delete)
- Seed: coach@example.com, athlete1/2@example.com (all pwd: password123)

---

## Implementation

### 1. Add Dependencies to `pom.xml`

```xml
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>1.6.3</version>
</dependency>
<!-- Add to maven-compiler-plugin annotationProcessorPaths -->
<path>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct-processor</artifactId>
    <version>1.6.3</version>
</path>
```

### 2. Configure `src/main/resources/application.yaml`

```yaml
spring:
  application:
    name: liftlogger
  datasource:
    url: jdbc:postgresql://localhost:5432/liftlogger
    username: postgres
    password: postgres
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        jdbc.time_zone: UTC
  session:
    store-type: jdbc
    timeout: 30d
    jdbc:
      initialize-schema: always
logging:
  level:
    com.example.liftlogger: DEBUG
```

---

## Domain Layer (`domain/`)

### `model/User.java`

```java
@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class User {
    private UUID id;
    private String email;
    private String passwordHash;
    private UserRole role;
    private UUID coachId; // null for coaches
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer version;
    private LocalDateTime deletedAt;
}
```

### `model/UserRole.java`

```java
public enum UserRole { COACH, ATHLETE }
```

### `exception/`

- `UserAlreadyExistsException(String email)`
- `InvalidCredentialsException()`
- `CoachNotFoundException(UUID coachId)`
- `InvalidRoleAssignmentException(String message)` (athlete without coachId)

### `outbound/repository/UserRepository.java`

```java
public interface UserRepository {
    User save(User user);
    Optional<User> findById(UUID id);
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    boolean existsById(UUID id);
}
```

---

## Application Layer (`application/`)

### `inbound/RegisterUserUseCase.java`

```java
public interface RegisterUserUseCase {
    User execute(String email, String rawPassword, UserRole role, UUID coachId);
}
```

### `inbound/LoginUserUseCase.java`, `GetCurrentUserUseCase.java`

Similar signatures: `User execute(email, password)`, `User execute()`

### `service/RegisterUserService.java`

```java
@Service @RequiredArgsConstructor
public class RegisterUserService implements RegisterUserUseCase {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public User execute(String email, String rawPassword, UserRole role, UUID coachId) {
        if (userRepository.existsByEmail(email))
            throw new UserAlreadyExistsException(email);

        if (role == UserRole.ATHLETE) {
            if (coachId == null)
                throw new InvalidRoleAssignmentException("Athlete must have coachId");
            if (!userRepository.existsById(coachId))
                throw new CoachNotFoundException(coachId);
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
```

### `service/LoginUserService.java`

```java
@Service @RequiredArgsConstructor
public class LoginUserService implements LoginUserUseCase {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public User execute(String email, String rawPassword) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(InvalidCredentialsException::new);

        if (!passwordEncoder.matches(rawPassword, user.getPasswordHash()))
            throw new InvalidCredentialsException();

        return user;
    }
}
```

### `service/GetCurrentUserService.java`

```java
@Service @RequiredArgsConstructor
public class GetCurrentUserService implements GetCurrentUserUseCase {
    private final UserRepository userRepository;

    @Override
    public User execute() {
        String email = SecurityContextHolder.getContext()
            .getAuthentication().getName();
        return userRepository.findByEmail(email)
            .orElseThrow(() -> new RuntimeException("User not found"));
    }
}
```

---

## Infrastructure - DB Layer (`infrastructure/db/`)

### `entity/UserJpaEntity.java`

```java
@Entity @Table(name = "users", indexes = {
    @Index(name = "idx_email", columnList = "email"),
    @Index(name = "idx_coach_id", columnList = "coach_id")
})
@Where(clause = "deleted_at IS NULL")
@Data @NoArgsConstructor @AllArgsConstructor
public class UserJpaEntity {
    @Id private UUID id;
    @Column(unique = true, nullable = false) private String email;
    @Column(nullable = false) private String passwordHash;
    @Enumerated(EnumType.STRING) private UserRole role;
    private UUID coachId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Integer version;
    private LocalDateTime deletedAt;
}
```

### `repository/UserJpaRepository.java`

```java
public interface UserJpaRepository extends JpaRepository<UserJpaEntity, UUID> {
    Optional<UserJpaEntity> findByEmail(String email);
    boolean existsByEmail(String email);
}
```

### `mapper/UserJpaMapper.java`

```java
@Mapper(componentModel = "spring")
public interface UserJpaMapper {
    User toDomain(UserJpaEntity entity);
    UserJpaEntity toEntity(User domain);
}
```

### `adapter/UserJpaAdapter.java`

```java
@Repository @RequiredArgsConstructor
public class UserJpaAdapter implements UserRepository {
    private final UserJpaRepository jpaRepository;
    private final UserJpaMapper mapper;

    @Override
    public User save(User user) {
        return mapper.toDomain(jpaRepository.save(mapper.toEntity(user)));
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return jpaRepository.findByEmail(email).map(mapper::toDomain);
    }

    @Override
    public boolean existsByEmail(String email) {
        return jpaRepository.existsByEmail(email);
    }

    @Override
    public Optional<User> findById(UUID id) {
        return jpaRepository.findById(id).map(mapper::toDomain);
    }

    @Override
    public boolean existsById(UUID id) {
        return jpaRepository.existsById(id);
    }
}
```

---

## Infrastructure - REST Layer (`infrastructure/rest/`)

### `controller/AuthController.java`

```java
@RestController @RequestMapping("/api/auth") @RequiredArgsConstructor
public class AuthController {
    private final RegisterUserUseCase registerUseCase;
    private final LoginUserUseCase loginUseCase;
    private final AuthRequestMapper requestMapper;
    private final AuthResponseMapper responseMapper;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@RequestBody @Valid RegisterRequest request) {
        User user = registerUseCase.execute(
            request.email(), request.password(), request.role(), request.coachId());
        return responseMapper.toResponse(user);
    }

    @PostMapping("/login")
    public AuthResponse login(@RequestBody @Valid LoginRequest request) {
        User user = loginUseCase.execute(request.email(), request.password());
        return responseMapper.toResponse(user);
    }

    @PostMapping("/logout")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void logout(HttpServletRequest request) {
        request.getSession().invalidate(); // Controller-level only, no use case
    }
}
```

### `dto/`

```java
public record RegisterRequest(
    @NotBlank String email,
    @NotBlank String password,
    @NotNull UserRole role,
    UUID coachId
) {}

public record LoginRequest(@NotBlank String email, @NotBlank String password) {}

public record AuthResponse(UUID id, String email, UserRole role, UUID coachId) {}
```

### `mapper/`

```java
@Mapper(componentModel = "spring")
public interface AuthRequestMapper {
    // Add mapping methods if needed
}

@Mapper(componentModel = "spring")
public interface AuthResponseMapper {
    AuthResponse toResponse(User user);
}
```

### `exception/AuthExceptionHandler.java`

```java
@RestControllerAdvice
public class AuthExceptionHandler {
    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<String> handle(UserAlreadyExistsException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ex.getMessage());
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<String> handle(InvalidCredentialsException ex) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }

    @ExceptionHandler(CoachNotFoundException.class)
    public ResponseEntity<String> handle(CoachNotFoundException ex) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ex.getMessage());
    }

    @ExceptionHandler(InvalidRoleAssignmentException.class)
    public ResponseEntity<String> handle(InvalidRoleAssignmentException ex) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(ex.getMessage());
    }
}
```

---

## Infrastructure - Security (`infrastructure/security/`)

### `config/SecurityConfig.java`

```java
@Configuration @EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable()) // Or configure for sessions
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/register", "/api/auth/login").permitAll()
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
            );
        return http.build();
    }
}
```

### `config/PasswordEncoderConfig.java`

```java
@Configuration
public class PasswordEncoderConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
```

### `service/CustomUserDetailsService.java`

```java
@Service @RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {
    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new UsernameNotFoundException(email));

        return org.springframework.security.core.userdetails.User.builder()
            .username(user.getEmail())
            .password(user.getPasswordHash())
            .authorities("ROLE_" + user.getRole().name())
            .build();
    }
}
```

---

## Infrastructure - Config (`infrastructure/config/`)

### `DataSeeder.java`

```java
@Component @RequiredArgsConstructor
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
```

---

## Verification

```bash

# 1. Run app
cd back && mvn spring-boot:run

# 2. Test register
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test123","role":"COACH"}'

# 3. Test login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" -c cookies.txt \
  -d '{"email":"coach@example.com","password":"password123"}'

# 4. Verify session
curl -X GET http://localhost:8080/api/protected -b cookies.txt

```
