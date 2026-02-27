package com.apiece.springboot_sns.domain.timeline;

import com.apiece.springboot_sns.domain.follow.FollowCountService;
import com.apiece.springboot_sns.domain.follow.FollowRepository;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostRepository;
import com.apiece.springboot_sns.domain.user.User;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.DefaultTypedTuple;
import org.springframework.data.redis.core.ZSetOperations;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class TimelineService {

  private final TimelineRepository timelineRepository;
  private final FollowRepository followRepository;
  private final FollowCountService followCountService;
  private final PostRepository postRepository;
  private final TimelineProperties timelineProperties;

  /** 쓰기 시 팬아웃 — 게시글 저장 후 팔로워 타임라인에 배포 */
  public void deliverToFollowers(Post post) {
    User author = post.getUser();
    boolean isCeleb = followCountService.getFollowerCount(author) >= timelineProperties.celebFollowerThreshold();

    double score = post.getCreatedAt().toEpochSecond(ZoneOffset.UTC);

    if (isCeleb) {
      timelineRepository.addToCeleb(author.getId(), post.getId(), score);
      timelineRepository.trimCelebToSize(author.getId());
      return;
    }

    List<Long> followerIds = followRepository.findFollowerIdsByFollowing(author);
    if (followerIds.isEmpty()) {
      return;
    }

    Set<ZSetOperations.TypedTuple<String>> tuple = Set.of(
        new DefaultTypedTuple<>(post.getId().toString(), score)
    );

    for (Long followerId : followerIds) {
      timelineRepository.addAll(followerId, tuple);
      timelineRepository.trimToSize(followerId);
    }
  }

  /** 타임라인 조회 — 내 ZSET + 팔로우한 각 celeb ZSET 병합 */
  public List<Post> getTimeline(User user, Double cursor, int size) {
    double maxScore = cursor != null ? cursor : Double.MAX_VALUE;

    // 내 ZSET에서 커서 기반 조회
    Set<ZSetOperations.TypedTuple<String>> myTuples =
        timelineRepository.getTimeline(user.getId(), maxScore, size);

    Set<Long> postIds = new LinkedHashSet<>();
    if (myTuples != null) {
      for (ZSetOperations.TypedTuple<String> tuple : myTuples) {
        if (tuple.getValue() != null) {
          postIds.add(Long.parseLong(tuple.getValue()));
        }
      }
    }

    // 내가 팔로우하는 celeb 목록 조회 후 각 ZSET에서 커서 기반 조회
    List<Long> followingIds = followRepository.findFollowingIdsByFollower(user);
    List<Long> celebIds = followCountService.getCelebIds(followingIds, timelineProperties.celebFollowerThreshold());

    for (Long celebId : celebIds) {
      Set<ZSetOperations.TypedTuple<String>> celebTuples =
          timelineRepository.getCelebTimeline(celebId, maxScore, size);
      if (celebTuples != null) {
        for (ZSetOperations.TypedTuple<String> tuple : celebTuples) {
          if (tuple.getValue() != null) {
            postIds.add(Long.parseLong(tuple.getValue()));
          }
        }
      }
    }

    if (postIds.isEmpty()) {
      return List.of();
    }

    // DB에서 게시글 일괄 조회 후 score 내림차순 정렬
    List<Post> posts = new ArrayList<>(postRepository.findAllByIdInWithUser(new ArrayList<>(postIds)));
    posts.sort(Comparator.comparing(Post::getCreatedAt).reversed());

    return posts.size() > size ? new ArrayList<>(posts.subList(0, size)) : posts;
  }
}
