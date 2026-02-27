package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import java.util.List;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class FollowCountService {

  private final FollowCountRepository followCountRepository;

  /** 팔로우 카운트 조회 */
  public FollowCount getFollowCount(User user) {
    return followCountRepository
        .findByUser(user)
        .orElseGet(() -> new FollowCount(user));
  }

  /** 팔로우 카운트 증가 */
  @Transactional
  public void incrementCounts(User follower, User following) {
    ensureFollowCountExists(follower);
    ensureFollowCountExists(following);
    followCountRepository.incrementFollowingCount(follower);
    followCountRepository.incrementFollowerCount(following);
  }

  /** 팔로우 카운트 감소 */
  @Transactional
  public void decrementCounts(User follower, User following) {
    ensureFollowCountExists(follower);
    ensureFollowCountExists(following);
    followCountRepository.decrementFollowingCount(follower);
    followCountRepository.decrementFollowerCount(following);
  }

  private void ensureFollowCountExists(User user) {
    if (followCountRepository.findByUser(user).isEmpty()) {
      createFollowCount(user);
    }
  }

  /** 팔로워 수 조회 (celeb 판단용) */
  public int getFollowerCount(User user) {
    return followCountRepository
        .findByUser(user)
        .map(FollowCount::getFollowerCount)
        .orElse(0);
  }

  /** celeb ID 목록 조회 */
  public List<Long> getCelebIds(List<Long> userIds, int threshold) {
    if (userIds.isEmpty()) {
      return List.of();
    }
    return followCountRepository.findCelebIds(userIds, threshold);
  }

  private void createFollowCount(User user) {
    try {
      followCountRepository.saveAndFlush(new FollowCount(user));
    } catch (DataIntegrityViolationException e) {
      log.debug("Concurrent follow count insert for user {}, ignoring.", user.getId());
    }
  }
}
