package com.apiece.springboot_sns.domain.like;

import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.user.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LikeRepository extends JpaRepository<Like, Long> {

  boolean existsByUserAndPost(User user, Post post);

  boolean existsByUserIdAndPostId(Long userId, Long postId);

  Optional<Like> findByUserAndPost(User user, Post post);
}
