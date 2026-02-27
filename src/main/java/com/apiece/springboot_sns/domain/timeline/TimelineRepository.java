package com.apiece.springboot_sns.domain.timeline;

import static com.apiece.springboot_sns.domain.timeline.TimelineConstants.CELEB_TIMELINE_KEY_PREFIX;
import static com.apiece.springboot_sns.domain.timeline.TimelineConstants.TIMELINE_KEY_PREFIX;

import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class TimelineRepository {

  private final StringRedisTemplate redisTemplate;
  private final TimelineProperties timelineProperties;

  /** 벌크 추가 (쓰기 시 팬아웃용) */
  public void addAll(Long userId, Set<ZSetOperations.TypedTuple<String>> entries) {
    String key = TIMELINE_KEY_PREFIX + userId;
    redisTemplate.opsForZSet().add(key, entries);
  }

  /** 커서 기반 조회 (score 내림차순) */
  public Set<ZSetOperations.TypedTuple<String>> getTimeline(Long userId, double maxScore, int size) {
    String key = TIMELINE_KEY_PREFIX + userId;
    return redisTemplate.opsForZSet()
        .reverseRangeByScoreWithScores(key, Double.NEGATIVE_INFINITY, maxScore, 0, size);
  }

  /** ZSET 크기를 maxTimelineSize로 제한 (오래된 항목 제거) */
  public void trimToSize(Long userId) {
    String key = TIMELINE_KEY_PREFIX + userId;
    Long size = redisTemplate.opsForZSet().size(key);
    int max = timelineProperties.maxTimelineSize();
    if (size != null && size > max) {
      redisTemplate.opsForZSet().removeRange(key, 0, size - max - 1);
    }
  }

  /** 셀럽 ZSET에 게시글 추가 */
  public void addToCeleb(Long celebId, Long postId, double score) {
    String key = CELEB_TIMELINE_KEY_PREFIX + celebId;
    redisTemplate.opsForZSet().add(key, postId.toString(), score);
  }

  /** 셀럽 ZSET 커서 기반 조회 (score 내림차순) */
  public Set<ZSetOperations.TypedTuple<String>> getCelebTimeline(Long celebId, double maxScore, int size) {
    String key = CELEB_TIMELINE_KEY_PREFIX + celebId;
    return redisTemplate.opsForZSet()
        .reverseRangeByScoreWithScores(key, Double.NEGATIVE_INFINITY, maxScore, 0, size);
  }

  /** 셀럽 ZSET 크기를 maxTimelineSize로 제한 */
  public void trimCelebToSize(Long celebId) {
    String key = CELEB_TIMELINE_KEY_PREFIX + celebId;
    Long size = redisTemplate.opsForZSet().size(key);
    int max = timelineProperties.maxTimelineSize();
    if (size != null && size > max) {
      redisTemplate.opsForZSet().removeRange(key, 0, size - max - 1);
    }
  }
}
