package com.apiece.springboot_sns.domain.post;

import com.apiece.springboot_sns.domain.common.BaseTimeEntity;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.persistence.*;
import java.time.Duration;
import java.time.LocalDateTime;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "posts")
@SQLDelete(sql = "UPDATE posts SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Post extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = PostConstants.MAX_CONTENT_LENGTH)
    private String content;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private User user;

    @Column(name = "parent_id")
    private Long parentId;

    @Column(name = "quote_id")
    private Long quoteId;

    @Column(name = "repost_id")
    private Long repostId;

    @Column(nullable = false)
    private Integer repostCount = 0;

    @Column(nullable = false)
    private Integer likeCount = 0;

    @Column(nullable = false)
    private Integer replyCount = 0;

    @Column(nullable = false)
    private Long viewCount = 0L;

    public static Post create(String content, User user) {
        Post post = new Post();
        post.content = content;
        post.user = user;
        return post;
    }

    public static Post createReply(String content, User user, Long parentId) {
        Post post = create(content, user);
        post.parentId = parentId;
        return post;
    }

    public static Post createQuote(String content, User user, Long quoteId) {
        Post post = create(content, user);
        post.quoteId = quoteId;
        return post;
    }

    public static Post createRepost(User user, Long repostId) {
        Post post = create("", user);
        post.repostId = repostId;
        return post;
    }

    public void updateContent(String content) {
        this.content = content;
    }

    public boolean isEditExpired(LocalDateTime now, Duration editWindow) {
        return this.getCreatedAt().isBefore(now.minus(editWindow));
    }

    public PostType getType() {
        if (repostId != null) return PostType.REPOST;
        if (quoteId != null) return PostType.QUOTE;
        if (parentId != null) return PostType.REPLY;
        return PostType.POST;
    }
}
