-- Clear all tables (child to parent order to avoid FK constraint violations)
DELETE FROM set_sessions;
DELETE FROM exercise_sessions;
DELETE FROM set_plans;
DELETE FROM exercise_plans;
DELETE FROM training_sessions;
DELETE FROM training_plans;
DELETE FROM body_weight_entries;
DELETE FROM variants;
DELETE FROM exercises;
DELETE FROM users;

-- The password hash corresponds to the plaintext password "password123"
INSERT INTO users (id, email, name, password_hash, role, coach_id, created_at, updated_at, version, deleted_at)
VALUES
    ('00000000-0000-0000-0000-000000000001', 'coach@example.com',    'Coach Smith',    '$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206', 'COACH',   NULL,                                   NOW(), NOW(), 1, NULL),
    ('00000000-0000-0000-0000-000000000002', 'athlete1@example.com', 'John Athlete',   '$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206', 'ATHLETE', '00000000-0000-0000-0000-000000000001', NOW(), NOW(), 1, NULL),
    ('00000000-0000-0000-0000-000000000003', 'athlete2@example.com', 'Jane Athlete',   '$2a$10$aAHXQfNDDwTtQHPuML6k3.hbGwbr5jyoYNcVzoLX4slrkTPyCH206', 'ATHLETE', '00000000-0000-0000-0000-000000000001', NOW(), NOW(), 1, NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 1: Add Exercises
-- ===========================
INSERT INTO exercises (id, coach_id, name, description, category, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001', 'Bench Press', 'Compound upper body pressing exercise targeting chest, shoulders, and triceps', 'Upper Body', NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL),
    ('00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0000-000000000001', 'Squat', 'Compound lower body exercise targeting quadriceps, glutes, and hamstrings', 'Lower Body', NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 2: Add Variants
-- ===========================
INSERT INTO variants (id, coach_id, exercise_id, name, description, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0002-000000000001', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000001', 'Close Grip', 'Bench press variation with narrow hand placement emphasizing triceps', NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL),
    ('00000000-0000-0000-0002-000000000002', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0001-000000000002', 'Front Squat', 'Squat variation with bar positioned on front deltoids, emphasizing quads', NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 3: Add Training Plan
-- ===========================
INSERT INTO training_plans (id, athlete_id, name, date, is_locked, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0000-000000000002', 'Upper Body Strength Program', '2026-02-01 00:00:00', false, NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 4: Add Exercise Plans
-- ===========================
INSERT INTO exercise_plans (id, athlete_id, training_plan_id, exercise_id, variant_id, order_index, notes, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0001-000000000001', NULL, 0, 'Focus on form', NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL),
    ('00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0003-000000000001', '00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0002-000000000002', 1, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 5: Add Set Plans
-- ===========================
INSERT INTO set_plans (id, athlete_id, exercise_plan_id, set_number, target_reps, target_weight, target_rpe, notes, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    -- Bench Press set plans
    ('00000000-0000-0000-0005-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0004-000000000001', 1, 8, 100.0, 7.0, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL),
    ('00000000-0000-0000-0005-000000000002', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0004-000000000001', 2, 6, 110.0, 8.0, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL),
    -- Front Squat set plans
    ('00000000-0000-0000-0005-000000000003', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0004-000000000002', 1, 10, 80.0, 7.0, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL),
    ('00000000-0000-0000-0005-000000000004', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0004-000000000002', 2, 8, 90.0, 8.0, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 6: Add Training Session
-- ===========================
INSERT INTO training_sessions (id, athlete_id, training_plan_id, session_date, notes, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0006-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0003-000000000001', '2026-02-05 10:00:00', 'First session of the program', NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 7: Add Exercise Sessions
-- ===========================
INSERT INTO exercise_sessions (id, athlete_id, training_session_id, exercise_plan_id, exercise_id, variant_id, order_index, notes, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0007-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0006-000000000001', '00000000-0000-0000-0004-000000000001', '00000000-0000-0000-0001-000000000001', '00000000-0000-0000-0002-000000000001', 0, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL),
    ('00000000-0000-0000-0007-000000000002', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0006-000000000001', '00000000-0000-0000-0004-000000000002', '00000000-0000-0000-0001-000000000002', '00000000-0000-0000-0002-000000000002', 1, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 8: Add Set Sessions
-- ===========================
INSERT INTO set_sessions (id, athlete_id, exercise_session_id, set_plan_id, set_number, actual_reps, actual_weight, actual_rpe, notes, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    -- Bench Press Close Grip set sessions
    ('00000000-0000-0000-0008-000000000001', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0007-000000000001', '00000000-0000-0000-0005-000000000001', 1, 8, 95.0, 7.0, 'Felt strong', NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL),
    ('00000000-0000-0000-0008-000000000002', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0007-000000000001', '00000000-0000-0000-0005-000000000002', 2, 7, 105.0, 8.5, 'Last rep was hard', NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL),
    -- Front Squat set sessions
    ('00000000-0000-0000-0008-000000000003', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0007-000000000002', '00000000-0000-0000-0005-000000000003', 1, 10, 80.0, 7.0, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL),
    ('00000000-0000-0000-0008-000000000004', '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0007-000000000002', '00000000-0000-0000-0005-000000000004', 2, 9, 85.0, 8.0, 'One less rep than planned', NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL)
ON CONFLICT (id) DO NOTHING;

-- ===========================
-- Step 9: Add Body Weight Entries
-- ===========================
INSERT INTO body_weight_entries (id, athlete_id, measurement_date, weight, notes, created_at, updated_at, created_by, updated_by, deleted_at)
VALUES
    ('00000000-0000-0000-0009-000000000001', '00000000-0000-0000-0000-000000000002', '2026-02-01 08:00:00', 75.5, 'Starting weight for the program', NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL),
    ('00000000-0000-0000-0009-000000000002', '00000000-0000-0000-0000-000000000002', '2026-02-08 08:00:00', 75.8, NULL, NOW(), NOW(), '00000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000002', NULL)
ON CONFLICT (id) DO NOTHING;
