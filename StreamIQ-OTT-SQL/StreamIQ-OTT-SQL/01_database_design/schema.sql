-- ============================================================
-- StreamIQ - OTT Streaming Analytics Database
-- schema.sql
-- Creates the normalized database structure only.
-- No sample data, views, procedures, functions, or triggers.
-- ============================================================

CREATE DATABASE IF NOT EXISTS streamiq
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE streamiq;

-- ============================================================
-- 1. USERS
-- ============================================================

CREATE TABLE users (
    user_id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50),
    email VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    country VARCHAR(50),
    registration_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE',

    PRIMARY KEY (user_id),
    UNIQUE KEY email (email)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 2. PROFILES
-- ============================================================

CREATE TABLE profiles (
    profile_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    profile_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    language VARCHAR(30),
    content_rating VARCHAR(20),

    PRIMARY KEY (profile_id),
    KEY user_id (user_id),
    CONSTRAINT profiles_ibfk_1
        FOREIGN KEY (user_id)
        REFERENCES users (user_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 3. DEVICES
-- ============================================================

CREATE TABLE devices (
    device_id INT NOT NULL AUTO_INCREMENT,
    profile_id INT NOT NULL,
    device_type VARCHAR(30) NOT NULL,
    device_name VARCHAR(100),
    operating_system VARCHAR(50),
    registered_date DATE,

    PRIMARY KEY (device_id),
    KEY profile_id (profile_id),
    CONSTRAINT devices_ibfk_1
        FOREIGN KEY (profile_id)
        REFERENCES profiles (profile_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 4. CONTENT
-- ============================================================

CREATE TABLE content (
    content_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content_type VARCHAR(20) NOT NULL,
    release_date DATE,
    duration_minutes INT,
    language VARCHAR(30),
    country VARCHAR(50),
    age_rating VARCHAR(10),
    description TEXT,

    PRIMARY KEY (content_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 5. EPISODES
-- ============================================================

CREATE TABLE episodes (
    episode_id INT NOT NULL AUTO_INCREMENT,
    content_id INT NOT NULL,
    season_number INT NOT NULL,
    episode_number INT NOT NULL,
    episode_title VARCHAR(200) NOT NULL,
    duration_minutes INT,
    release_date DATE,

    PRIMARY KEY (episode_id),
    UNIQUE KEY content_id (content_id, season_number, episode_number),
    CONSTRAINT episodes_ibfk_1
        FOREIGN KEY (content_id)
        REFERENCES content (content_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 6. GENRES
-- ============================================================

CREATE TABLE genres (
    genre_id INT NOT NULL AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL,
    description VARCHAR(255),

    PRIMARY KEY (genre_id),
    UNIQUE KEY genre_name (genre_name)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 7. CONTENT_GENRES
-- ============================================================

CREATE TABLE content_genres (
    content_id INT NOT NULL,
    genre_id INT NOT NULL,

    PRIMARY KEY (content_id, genre_id),
    KEY genre_id (genre_id),

    CONSTRAINT content_genres_ibfk_1
        FOREIGN KEY (content_id)
        REFERENCES content (content_id),

    CONSTRAINT content_genres_ibfk_2
        FOREIGN KEY (genre_id)
        REFERENCES genres (genre_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 8. ACTORS
-- ============================================================

CREATE TABLE actors (
    actor_id INT NOT NULL AUTO_INCREMENT,
    actor_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    country VARCHAR(50),

    PRIMARY KEY (actor_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 9. CONTENT_CAST
-- ============================================================

CREATE TABLE content_cast (
    content_id INT NOT NULL,
    actor_id INT NOT NULL,
    character_name VARCHAR(100),

    PRIMARY KEY (content_id, actor_id),
    KEY actor_id (actor_id),

    CONSTRAINT content_cast_ibfk_1
        FOREIGN KEY (content_id)
        REFERENCES content (content_id),

    CONSTRAINT content_cast_ibfk_2
        FOREIGN KEY (actor_id)
        REFERENCES actors (actor_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 10. SUBSCRIPTION_PLANS
-- ============================================================

CREATE TABLE subscription_plans (
    plan_id INT NOT NULL AUTO_INCREMENT,
    plan_name VARCHAR(50) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    billing_cycle VARCHAR(20) NOT NULL,
    max_devices INT NOT NULL,
    video_quality VARCHAR(20) NOT NULL,

    PRIMARY KEY (plan_id),
    UNIQUE KEY plan_name (plan_name)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 11. SUBSCRIPTIONS
-- ============================================================

CREATE TABLE subscriptions (
    subscription_id INT NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    auto_renew TINYINT(1) DEFAULT '1',

    PRIMARY KEY (subscription_id),
    KEY user_id (user_id),
    KEY plan_id (plan_id),

    CONSTRAINT subscriptions_ibfk_1
        FOREIGN KEY (user_id)
        REFERENCES users (user_id),

    CONSTRAINT subscriptions_ibfk_2
        FOREIGN KEY (plan_id)
        REFERENCES subscription_plans (plan_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 12. PAYMENTS
-- ============================================================

CREATE TABLE payments (
    payment_id INT NOT NULL AUTO_INCREMENT,
    subscription_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    transaction_reference VARCHAR(100),

    PRIMARY KEY (payment_id),
    UNIQUE KEY transaction_reference (transaction_reference),
    KEY subscription_id (subscription_id),
    KEY idx_payments_date_status (payment_date, payment_status),

    CONSTRAINT payments_ibfk_1
        FOREIGN KEY (subscription_id)
        REFERENCES subscriptions (subscription_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 13. WATCH_HISTORY
-- ============================================================

CREATE TABLE watch_history (
    watch_id INT NOT NULL AUTO_INCREMENT,
    profile_id INT NOT NULL,
    device_id INT,
    content_id INT NOT NULL,
    episode_id INT,
    watch_start DATETIME NOT NULL,
    watch_end DATETIME,
    watch_duration_minutes INT,
    completion_percentage DECIMAL(5,2),

    PRIMARY KEY (watch_id),
    KEY episode_id (episode_id),
    KEY fk_watch_device (device_id),
    KEY idx_watch_profile_start (profile_id, watch_start),
    KEY idx_watch_content (content_id),

    CONSTRAINT fk_watch_device
        FOREIGN KEY (device_id)
        REFERENCES devices (device_id),

    CONSTRAINT watch_history_ibfk_1
        FOREIGN KEY (profile_id)
        REFERENCES profiles (profile_id),

    CONSTRAINT watch_history_ibfk_2
        FOREIGN KEY (content_id)
        REFERENCES content (content_id),

    CONSTRAINT watch_history_ibfk_3
        FOREIGN KEY (episode_id)
        REFERENCES episodes (episode_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- 14. RATINGS
-- ============================================================

CREATE TABLE ratings (
    rating_id INT NOT NULL AUTO_INCREMENT,
    profile_id INT NOT NULL,
    content_id INT NOT NULL,
    rating DECIMAL(2,1) NOT NULL,
    review_text VARCHAR(500),
    rated_at DATETIME NOT NULL,

    PRIMARY KEY (rating_id),
    UNIQUE KEY profile_id (profile_id, content_id),
    KEY content_id (content_id),

    CONSTRAINT ratings_ibfk_1
        FOREIGN KEY (profile_id)
        REFERENCES profiles (profile_id),

    CONSTRAINT ratings_ibfk_2
        FOREIGN KEY (content_id)
        REFERENCES content (content_id)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- End of schema.sql
-- ============================================================
