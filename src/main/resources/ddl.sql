-- =====================
-- users
-- =====================
CREATE TABLE users (
    id         BIGSERIAL    PRIMARY KEY,
    email      VARCHAR(255) NOT NULL,
    password   VARCHAR(255) NOT NULL,
    username   VARCHAR(255) NOT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    deleted_at TIMESTAMP
);

-- UserRepository.existsByEmail / findByEmail
CREATE UNIQUE INDEX uk_users_email ON users (email);

-- =====================
-- follows
-- =====================
CREATE TABLE follows (
    id           BIGSERIAL PRIMARY KEY,
    follower_id  BIGINT,
    following_id BIGINT,
    created_at   TIMESTAMP,
    updated_at   TIMESTAMP,
    deleted_at   TIMESTAMP
);

-- FollowRepository.existsByFollowerAndFollowing / findByFollowerAndFollowing
-- FollowRepository.findByFollower (follower_id 가 선행 컬럼이므로 커버)
CREATE UNIQUE INDEX uk_follows_follower_following ON follows (follower_id, following_id);

-- FollowRepository.findByFollowing (팔로워 목록 조회)
-- 복합 인덱스의 선행 컬럼이 아니므로 별도 인덱스 필요
CREATE INDEX idx_follows_following_id ON follows (following_id);

-- =====================
-- follow_counts
-- =====================
CREATE TABLE follow_counts (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT,
    follower_count  INT     NOT NULL DEFAULT 0,
    following_count INT     NOT NULL DEFAULT 0,
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    deleted_at      TIMESTAMP
);

-- FollowCountRepository.findByUser
CREATE UNIQUE INDEX uk_follow_counts_user_id ON follow_counts (user_id);
