package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
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
}
