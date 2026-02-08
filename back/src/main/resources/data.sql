DELETE FROM users;

-- The password hash corresponds to the plaintext password "password123"
INSERT INTO users (id, email, password_hash, role, coach_id, created_at, updated_at, version, deleted_at)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'coach@example.com',    '$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206', 'COACH',   NULL,                                   NOW(), NOW(), 1, NULL),
    ('00000000-0000-0000-0000-000000000002', 'athlete1@example.com', '$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206', 'ATHLETE', '00000000-0000-0000-0000-000000000001', NOW(), NOW(), 1, NULL),
    ('00000000-0000-0000-0000-000000000003', 'athlete2@example.com', '$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206', 'ATHLETE', '00000000-0000-0000-0000-000000000001', NOW(), NOW(), 1, NULL)
ON CONFLICT (id) DO NOTHING;
