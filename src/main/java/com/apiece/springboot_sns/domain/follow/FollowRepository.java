package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FollowRepository extends JpaRepository<Follow, Long> {

  boolean existsByFollowerAndFollowing(User follower, User following);

  Optional<Follow> findByFollowerAndFollowing(User follower, User following);

  Page<Follow> findByFollowing(User following, Pageable pageable);

  Page<Follow> findByFollower(User follower, Pageable pageable);

  @Modifying
  @Query("UPDATE Follow f SET f.deletedAt = CURRENT_TIMESTAMP WHERE f.id = :id")
  void softDelete(@Param("id") Long id);

  /** 팬아웃을 위한 팔로워 ID 전체 조회 */
  @Query("SELECT f.follower.id FROM Follow f WHERE f.following = :following")
  List<Long> findFollowerIdsByFollowing(@Param("following") User following);

  /** 내가 팔로우하는 사람 ID 전체 조회 */
  @Query("SELECT f.following.id FROM Follow f WHERE f.follower = :follower")
  List<Long> findFollowingIdsByFollower(@Param("follower") User follower);
}
