package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface FollowCountRepository extends JpaRepository<FollowCount, Long> {

  Optional<FollowCount> findByUser(User user);

  @Modifying
  @Query("UPDATE FollowCount fc SET fc.followingCount = fc.followingCount + 1 WHERE fc.user = :user")
  void incrementFollowingCount(@Param("user") User user);

  @Modifying
  @Query("UPDATE FollowCount fc SET fc.followingCount = fc.followingCount - 1 WHERE fc.user = :user")
  void decrementFollowingCount(@Param("user") User user);

  @Modifying
  @Query("UPDATE FollowCount fc SET fc.followerCount = fc.followerCount + 1 WHERE fc.user = :user")
  void incrementFollowerCount(@Param("user") User user);

  @Modifying
  @Query("UPDATE FollowCount fc SET fc.followerCount = fc.followerCount - 1 WHERE fc.user = :user")
  void decrementFollowerCount(@Param("user") User user);

  /** celeb ID 목록 조회 (팔로워 수 기준) */
  @Query("SELECT fc.user.id FROM FollowCount fc WHERE fc.user.id IN :userIds AND fc.followerCount >= :threshold")
  List<Long> findCelebIds(@Param("userIds") List<Long> userIds, @Param("threshold") int threshold);
}
