package com.apiece.springboot_sns.api.dto.post;

import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostType;
import java.time.LocalDateTime;

public record PostResponse(
        Long id,

        String content,

        String username,

        PostType type,

        Long parentId,

        Long quoteId,

        Long repostId,

        Integer repostCount,

        Integer likeCount,

        Integer replyCount,

        Long viewCount,

        OriginalPostResponse originalPost,

        LocalDateTime createdAt,

        LocalDateTime updatedAt
) {

    public static PostResponse from(Post post) {
        return new PostResponse(
                post.getId(),
                post.getContent(),
                post.getUser().getUsername(),
                post.getType(),
                post.getParentId(),
                post.getQuoteId(),
                post.getRepostId(),
                post.getRepostCount(),
                post.getLikeCount(),
                post.getReplyCount(),
                post.getViewCount(),
                null,
                post.getCreatedAt(),
                post.getUpdatedAt()
        );
    }

    public static PostResponse from(Post post, Post original) {
        return new PostResponse(
                post.getId(),
                post.getContent(),
                post.getUser().getUsername(),
                post.getType(),
                post.getParentId(),
                post.getQuoteId(),
                post.getRepostId(),
                post.getRepostCount(),
                post.getLikeCount(),
                post.getReplyCount(),
                post.getViewCount(),
                original != null ? OriginalPostResponse.from(original) : null,
                post.getCreatedAt(),
                post.getUpdatedAt()
        );
    }
}
