package com.apiece.springboot_sns.domain.postView;

import static com.apiece.springboot_sns.domain.postView.PostViewConstants.DIRTY_SET_KEY;
import static com.apiece.springboot_sns.domain.postView.PostViewConstants.VIEW_COUNT_KEY_PREFIX;

import java.nio.charset.StandardCharsets;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class PostViewRepository {

    private final StringRedisTemplate redisTemplate;

    public void increment(Long postId) {
        byte[] key = (VIEW_COUNT_KEY_PREFIX + postId).getBytes(StandardCharsets.UTF_8);
        byte[] dirtySetKey = DIRTY_SET_KEY.getBytes(StandardCharsets.UTF_8);
        byte[] member = postId.toString().getBytes(StandardCharsets.UTF_8);

        redisTemplate.executePipelined((RedisCallback<Object>) connection -> {
            connection.stringCommands().incr(key);
            connection.setCommands().sAdd(dirtySetKey, member);
            return null;
        });
    }

    public Set<String> getDirtyPostIds() {
        return redisTemplate.opsForSet().members(DIRTY_SET_KEY);
    }

    public long getAndResetCount(Long postId) {
        String key = VIEW_COUNT_KEY_PREFIX + postId;
        String countStr = redisTemplate.opsForValue().getAndDelete(key);
        return countStr == null ? 0 : Long.parseLong(countStr);
    }

    public void removeDirty(String postIdStr) {
        redisTemplate.opsForSet().remove(DIRTY_SET_KEY, postIdStr);
    }
}
