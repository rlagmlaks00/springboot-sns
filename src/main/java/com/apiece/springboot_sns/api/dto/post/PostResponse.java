package com.apiece.springboot_sns.api.dto.post;

import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostType;
import java.time.LocalDateTime;
import java.util.List;

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

    List<Long> mediaIds,

    OriginalPostResponse originalPost,

    LocalDateTime createdAt,

    LocalDateTime updatedAt
) {

  public static PostResponse from(Post post) {
    return from(post, null);
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
        post.getMediaIds() != null ? post.getMediaIds() : List.of(),
        original != null ? OriginalPostResponse.from(original) : null,
        post.getCreatedAt(),
        post.getUpdatedAt()
    );
  }
}
