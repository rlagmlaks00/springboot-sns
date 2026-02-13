package com.apiece.springboot_sns.domain.post;

import com.apiece.springboot_sns.domain.user.User;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface PostRepository extends JpaRepository<Post, Long> {

    Page<Post> findByUser(User user, Pageable pageable);

    boolean existsByUserAndQuoteId(User user, Long quoteId);

    boolean existsByUserAndRepostId(User user, Long repostId);

    @Query("SELECT p FROM Post p JOIN FETCH p.user WHERE p.id = :id")
    Optional<Post> findByIdWithUser(@Param("id") Long id);

    @Query(value = "SELECT p FROM Post p JOIN FETCH p.user WHERE p.user = :user",
            countQuery = "SELECT count(p) FROM Post p WHERE p.user = :user")
    Page<Post> findByUserWithUser(@Param("user") User user, Pageable pageable);

    @Query(value = "SELECT p FROM Post p JOIN FETCH p.user WHERE p.parentId = :parentId",
            countQuery = "SELECT count(p) FROM Post p WHERE p.parentId = :parentId")
    Page<Post> findRepliesByParentId(@Param("parentId") Long parentId, Pageable pageable);

    @Query(value = "SELECT p FROM Post p JOIN FETCH p.user WHERE p.quoteId = :quoteId",
            countQuery = "SELECT count(p) FROM Post p WHERE p.quoteId = :quoteId")
    Page<Post> findQuotesByQuoteId(@Param("quoteId") Long quoteId, Pageable pageable);

    Optional<Post> findByUserAndRepostId(User user, Long repostId);

    Optional<Post> findByUserAndQuoteId(User user, Long quoteId);

    @Modifying
    @Query("UPDATE Post p SET p.replyCount = p.replyCount + 1 WHERE p.id = :id")
    void incrementReplyCount(@Param("id") Long id);

    @Modifying
    @Query("UPDATE Post p SET p.repostCount = p.repostCount + 1 WHERE p.id = :id")
    void incrementRepostCount(@Param("id") Long id);

    @Modifying
    @Query("UPDATE Post p SET p.repostCount = p.repostCount - 1 WHERE p.id = :id AND p.repostCount > 0")
    void decrementRepostCount(@Param("id") Long id);

    @Modifying
    @Query("UPDATE Post p SET p.replyCount = p.replyCount - 1 WHERE p.id = :id AND p.replyCount > 0")
    void decrementReplyCount(@Param("id") Long id);

    @Modifying
    @Query("UPDATE Post p SET p.likeCount = p.likeCount + 1 WHERE p.id = :id")
    void incrementLikeCount(@Param("id") Long id);

    @Modifying
    @Query("UPDATE Post p SET p.likeCount = p.likeCount - 1 WHERE p.id = :id AND p.likeCount > 0")
    void decrementLikeCount(@Param("id") Long id);
}
