-- Clean existing data
DELETE FROM set_sessions;
DELETE FROM exercise_session_variants;
DELETE FROM exercise_sessions;
DELETE FROM training_sessions;
DELETE FROM set_plans;
DELETE FROM exercise_plan_variants;
DELETE FROM exercise_plans;
DELETE FROM training_plans;
DELETE FROM body_weight_entries;
DELETE FROM variants;
DELETE FROM exercises;
DELETE FROM users;


-- ===========================================================================================
-- EXERCISES (Coach-owned) - All marked as dirty for push sync
-- ===========================================================================================
INSERT INTO exercises (
    id, coach_id, name, description, category,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    -- Upper Body
    ('e0000000-0000-0000-0001-000000000001', '00000000-0000-0000-0000-000000000001', 'Bench Press', 'Compound upper body pressing exercise targeting chest, shoulders, and triceps', 'Upper Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000002', '00000000-0000-0000-0000-000000000001', 'Overhead Press', 'Shoulder pressing movement for deltoid development', 'Upper Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000003', '00000000-0000-0000-0000-000000000001', 'Pull-Up', 'Vertical pulling exercise for back and biceps', 'Upper Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000004', '00000000-0000-0000-0000-000000000001', 'Barbell Row', 'Horizontal pulling exercise for back thickness', 'Upper Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000005', '00000000-0000-0000-0000-000000000001', 'Dumbbell Flyes', 'Isolation exercise for chest', 'Upper Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Lower Body
    ('e0000000-0000-0000-0001-000000000006', '00000000-0000-0000-0000-000000000001', 'Squat', 'Compound lower body exercise targeting quadriceps, glutes, and hamstrings', 'Lower Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000007', '00000000-0000-0000-0000-000000000001', 'Deadlift', 'Full body posterior chain exercise', 'Lower Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000008', '00000000-0000-0000-0000-000000000001', 'Leg Press', 'Machine-based quad dominant exercise', 'Lower Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000009', '00000000-0000-0000-0000-000000000001', 'Romanian Deadlift', 'Hip hinge exercise emphasizing hamstrings', 'Lower Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000010', '00000000-0000-0000-0000-000000000001', 'Leg Extension', 'Isolation exercise for quadriceps', 'Lower Body', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Arms
    ('e0000000-0000-0000-0001-000000000011', '00000000-0000-0000-0000-000000000001', 'Bicep Curl', 'Isolation exercise for biceps', 'Arms', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000012', '00000000-0000-0000-0000-000000000001', 'Tricep Extension', 'Isolation exercise for triceps', 'Arms', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000013', '00000000-0000-0000-0000-000000000001', 'Hammer Curl', 'Bicep exercise emphasizing brachialis', 'Arms', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('e0000000-0000-0000-0001-000000000014', '00000000-0000-0000-0000-000000000001', 'Skull Crusher', 'Lying tricep extension', 'Arms', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Core
    ('e0000000-0000-0000-0001-000000000015', '00000000-0000-0000-0000-000000000001', 'Plank', 'Isometric core exercise', 'Core', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- VARIANTS (Coach-owned) - All marked as dirty for push sync
-- ===========================================================================================
INSERT INTO variants (
    id, coach_id, name, description,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    -- Bench Press Variants
    ('b0000000-0000-0000-0002-000000000001', '00000000-0000-0000-0000-000000000001', 'Close Grip', 'Narrow hand placement emphasizing triceps', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000002', '00000000-0000-0000-0000-000000000001', 'Incline', 'Angled bench targeting upper chest', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000003', '00000000-0000-0000-0000-000000000001', 'Decline', 'Angled bench targeting lower chest', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000004', '00000000-0000-0000-0000-000000000001', 'Paused', 'Bench press with pause at bottom', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Squat Variants
    ('b0000000-0000-0000-0002-000000000005', '00000000-0000-0000-0000-000000000001', 'Front Squat', 'Bar positioned on front deltoids, emphasizing quads', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000006', '00000000-0000-0000-0000-000000000001', 'Box Squat', 'Squat with box for depth control', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000007', '00000000-0000-0000-0000-000000000001', 'Pause Squat', 'Squat with pause at bottom', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000008', '00000000-0000-0000-0000-000000000001', 'High Bar', 'Bar positioned high on traps', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Pull-Up Variants
    ('b0000000-0000-0000-0002-000000000009', '00000000-0000-0000-0000-000000000001', 'Weighted', 'Pull-up with added weight', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000010', '00000000-0000-0000-0000-000000000001', 'Chin-Up', 'Underhand grip pull-up', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000011', '00000000-0000-0000-0000-000000000001', 'Wide Grip', 'Extra wide grip for lat emphasis', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Deadlift Variants
    ('b0000000-0000-0000-0002-000000000012', '00000000-0000-0000-0000-000000000001', 'Sumo', 'Wide stance deadlift variation', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000013', '00000000-0000-0000-0000-000000000001', 'Deficit', 'Deadlift from elevated platform', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000014', '00000000-0000-0000-0000-000000000001', 'Trap Bar', 'Using trap/hex bar', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Curl Variants
    ('b0000000-0000-0000-0002-000000000015', '00000000-0000-0000-0000-000000000001', 'Preacher', 'Using preacher bench for isolation', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('b0000000-0000-0000-0002-000000000016', '00000000-0000-0000-0000-000000000001', 'Cable', 'Using cable machine for constant tension', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

INSERT INTO training_plans (
    id, athlete_id, name, date, is_locked,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    ('01000000-0000-0000-0003-000000000001', '00000000-0000-0000-0000-000000000002', 'Upper Body Strength - Week 1', '2026-02-03', 0, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('01000000-0000-0000-0003-000000000002', '00000000-0000-0000-0000-000000000002', 'Lower Body Hypertrophy - Week 1', '2026-02-05', 0, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('01000000-0000-0000-0003-000000000003', '00000000-0000-0000-0000-000000000002', 'Push Day', '2026-02-07', 0, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- EXERCISE PLANS - Linked to training plans
-- ===========================================================================================
INSERT INTO exercise_plans (
    id, athlete_id, training_plan_id, exercise_id, order_index, notes,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    -- Upper Body Plan
    ('02000000-0000-0000-0004-000000000001', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000001', 'e0000000-0000-0000-0001-000000000001', 0, 'Focus on controlled eccentric', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000002', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000001', 'e0000000-0000-0000-0001-000000000002', 1, 'Strict form, no leg drive', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000003', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000001', 'e0000000-0000-0000-0001-000000000003', 2, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000004', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000001', 'e0000000-0000-0000-0001-000000000011', 3, 'Superset with triceps', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Lower Body Plan
    ('02000000-0000-0000-0004-000000000005', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000002', 'e0000000-0000-0000-0001-000000000006', 0, 'ATG depth', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000006', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000002', 'e0000000-0000-0000-0001-000000000009', 1, 'Stretch hamstrings', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000007', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000002', 'e0000000-0000-0000-0001-000000000008', 2, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000008', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000002', 'e0000000-0000-0000-0001-000000000010', 3, 'Control the weight', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Push Day Plan
    ('02000000-0000-0000-0004-000000000009', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000003', 'e0000000-0000-0000-0001-000000000001', 0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000010', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000003', 'e0000000-0000-0000-0001-000000000002', 1, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('02000000-0000-0000-0004-000000000011', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000003', 'e0000000-0000-0000-0001-000000000012', 2, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- EXERCISE PLAN VARIANTS - Link variants to exercise plans
-- ===========================================================================================
INSERT INTO exercise_plan_variants (
    id, athlete_id, exercise_plan_id, variant_id,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    ('0a000000-0000-0000-000a-000000000001', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000001', 'b0000000-0000-0000-0002-000000000002', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL), -- Incline Bench
    ('0a000000-0000-0000-000a-000000000002', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000003', 'b0000000-0000-0000-0002-000000000009', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL), -- Weighted Pull-Up
    ('0a000000-0000-0000-000a-000000000003', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000005', 'b0000000-0000-0000-0002-000000000005', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL), -- Front Squat
    ('0a000000-0000-0000-000a-000000000004', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000009', 'b0000000-0000-0000-0002-000000000003', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL); -- Decline Bench

-- ===========================================================================================
-- SET PLANS - Target sets for each exercise
-- ===========================================================================================
INSERT INTO set_plans (
    id, athlete_id, exercise_plan_id, set_number, target_reps, target_weight, target_rpe, notes,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    -- Incline Bench (ep...0001)
    ('04000000-0000-0000-0005-000000000001', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000001', 1, 10, 80.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000002', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000001', 2, 8, 90.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000003', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000001', 3, 6, 95.0, 9.0, 'Push to limit', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Overhead Press (ep...0002)
    ('04000000-0000-0000-0005-000000000004', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000002', 1, 8, 50.0, 7.5, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000005', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000002', 2, 6, 55.0, 8.5, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000006', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000002', 3, 6, 55.0, 9.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Weighted Pull-Ups (ep...0003)
    ('04000000-0000-0000-0005-000000000007', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000003', 1, 8, 10.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000008', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000003', 2, 6, 15.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000009', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000003', 3, 5, 17.5, 9.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Bicep Curls (ep...0004)
    ('04000000-0000-0000-0005-000000000010', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000004', 1, 12, 15.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000011', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000004', 2, 12, 15.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Front Squat (ep...0005)
    ('04000000-0000-0000-0005-000000000012', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000005', 1, 10, 100.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000013', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000005', 2, 8, 110.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000014', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000005', 3, 6, 115.0, 9.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Romanian Deadlift (ep...0006)
    ('04000000-0000-0000-0005-000000000015', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000006', 1, 10, 90.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('04000000-0000-0000-0005-000000000016', '00000000-0000-0000-0000-000000000002', '02000000-0000-0000-0004-000000000006', 2, 8, 100.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- TRAINING SESSIONS - Completed workouts (dirty, ready to push)
-- ===========================================================================================
INSERT INTO training_sessions (
    id, athlete_id, training_plan_id, session_date, notes,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    ('05000000-0000-0000-0006-000000000001', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000001', '2026-02-03', 'Great upper body session, felt strong!', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('05000000-0000-0000-0006-000000000002', '00000000-0000-0000-0000-000000000002', '01000000-0000-0000-0003-000000000002', '2026-02-05', 'Legs are on fire! Good session', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- EXERCISE SESSIONS - Exercises performed in training sessions
-- ===========================================================================================
INSERT INTO exercise_sessions (
    id, athlete_id, training_session_id, exercise_plan_id, exercise_id, order_index, notes,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    -- Upper Body Session
    ('06000000-0000-0000-0007-000000000001', '00000000-0000-0000-0000-000000000002', '05000000-0000-0000-0006-000000000001', '02000000-0000-0000-0004-000000000001', 'e0000000-0000-0000-0001-000000000001', 0, 'Incline felt smooth', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('06000000-0000-0000-0007-000000000002', '00000000-0000-0000-0000-000000000002', '05000000-0000-0000-0006-000000000001', '02000000-0000-0000-0004-000000000002', 'e0000000-0000-0000-0001-000000000002', 1, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('06000000-0000-0000-0007-000000000003', '00000000-0000-0000-0000-000000000002', '05000000-0000-0000-0006-000000000001', '02000000-0000-0000-0004-000000000003', 'e0000000-0000-0000-0001-000000000003', 2, 'Added 2.5kg weight', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('06000000-0000-0000-0007-000000000004', '00000000-0000-0000-0000-000000000002', '05000000-0000-0000-0006-000000000001', '02000000-0000-0000-0004-000000000004', 'e0000000-0000-0000-0001-000000000011', 3, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Lower Body Session
    ('06000000-0000-0000-0007-000000000005', '00000000-0000-0000-0000-000000000002', '05000000-0000-0000-0006-000000000002', '02000000-0000-0000-0004-000000000005', 'e0000000-0000-0000-0001-000000000006', 0, 'Perfect depth on all reps', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('06000000-0000-0000-0007-000000000006', '00000000-0000-0000-0000-000000000002', '05000000-0000-0000-0006-000000000002', '02000000-0000-0000-0004-000000000006', 'e0000000-0000-0000-0001-000000000009', 1, 'Great hamstring stretch', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- EXERCISE SESSION VARIANTS
-- ===========================================================================================
INSERT INTO exercise_session_variants (
    id, athlete_id, exercise_session_id, variant_id,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    ('0b000000-0000-0000-000b-000000000001', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000001', 'b0000000-0000-0000-0002-000000000002', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL), -- Incline
    ('0b000000-0000-0000-000b-000000000002', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000003', 'b0000000-0000-0000-0002-000000000009', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL), -- Weighted Pull-Up
    ('0b000000-0000-0000-000b-000000000003', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000005', 'b0000000-0000-0000-0002-000000000005', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL); -- Front Squat

-- ===========================================================================================
-- SET SESSIONS - Actual performance data
-- ===========================================================================================
INSERT INTO set_sessions (
    id, athlete_id, exercise_session_id, set_plan_id, set_number, actual_reps, actual_weight, actual_rpe, notes,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    -- Incline Bench Sets
    ('08000000-0000-0000-0008-000000000001', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000001', '04000000-0000-0000-0005-000000000001', 1, 10, 80.0, 7.0, 'Smooth reps', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000002', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000001', '04000000-0000-0000-0005-000000000002', 2, 8, 90.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000003', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000001', '04000000-0000-0000-0005-000000000003', 3, 7, 92.5, 9.5, 'Had to reduce weight', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Overhead Press Sets
    ('08000000-0000-0000-0008-000000000004', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000002', '04000000-0000-0000-0005-000000000004', 1, 8, 50.0, 7.5, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000005', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000002', '04000000-0000-0000-0005-000000000005', 2, 6, 55.0, 8.5, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Weighted Pull-Up Sets
    ('08000000-0000-0000-0008-000000000006', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000003', '04000000-0000-0000-0005-000000000007', 1, 8, 10.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000007', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000003', '04000000-0000-0000-0005-000000000008', 2, 6, 15.0, 8.5, 'Very challenging', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Bicep Curl Sets
    ('08000000-0000-0000-0008-000000000008', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000004', '04000000-0000-0000-0005-000000000010', 1, 12, 15.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000009', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000004', '04000000-0000-0000-0005-000000000011', 2, 12, 15.0, 8.0, 'Great pump!', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Front Squat Sets
    ('08000000-0000-0000-0008-000000000010', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000005', '04000000-0000-0000-0005-000000000012', 1, 10, 100.0, 7.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000011', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000005', '04000000-0000-0000-0005-000000000013', 2, 8, 110.0, 8.0, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000012', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000005', '04000000-0000-0000-0005-000000000014', 3, 6, 115.0, 9.5, 'PR on last set!', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),

    -- Romanian Deadlift Sets
    ('08000000-0000-0000-0008-000000000013', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000006', '04000000-0000-0000-0005-000000000015', 1, 10, 90.0, 7.0, 'Good stretch', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('08000000-0000-0000-0008-000000000014', '00000000-0000-0000-0000-000000000002', '06000000-0000-0000-0007-000000000006', '04000000-0000-0000-0005-000000000016', 2, 8, 100.0, 8.5, NULL, strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);

-- ===========================================================================================
-- BODY WEIGHT ENTRIES
-- ===========================================================================================
INSERT INTO body_weight_entries (
    id, athlete_id, measurement_date, weight, notes,
    created_at, updated_at, version, deleted_at, is_dirty, last_synced_at
) VALUES
    ('09000000-0000-0000-0009-000000000001', '00000000-0000-0000-0000-000000000002', '2026-02-01', 82.5, 'Starting weight for bulk', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('09000000-0000-0000-0009-000000000002', '00000000-0000-0000-0000-000000000002', '2026-02-08', 82.8, 'Slight gain', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL),
    ('09000000-0000-0000-0009-000000000003', '00000000-0000-0000-0000-000000000002', '2026-02-15', 83.1, 'Gaining steadily', strftime('%s', 'now'), strftime('%s', 'now'), 1, NULL, 1, NULL);
