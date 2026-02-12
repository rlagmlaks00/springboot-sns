CREATE UNIQUE INDEX IF NOT EXISTS uk_posts_user_repost ON posts (user_id, repost_id) WHERE repost_id IS NOT NULL AND deleted_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS uk_posts_user_quote ON posts (user_id, quote_id) WHERE quote_id IS NOT NULL AND deleted_at IS NULL;
