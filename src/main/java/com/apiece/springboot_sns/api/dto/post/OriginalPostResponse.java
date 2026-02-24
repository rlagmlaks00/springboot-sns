package com.apiece.springboot_sns.api.dto.post;

import com.apiece.springboot_sns.domain.post.Post;
import java.time.LocalDateTime;

public record OriginalPostResponse(
    Long id,

    String content,

    String username,

    Integer repostCount,

    Integer likeCount,

    Integer replyCount,

    Long viewCount,

    LocalDateTime createdAt
) {

  public static OriginalPostResponse from(Post post) {
    return new OriginalPostResponse(
        post.getId(),
        post.getContent(),
        post.getUser().getUsername(),
        post.getRepostCount(),
        post.getLikeCount(),
        post.getReplyCount(),
        post.getViewCount(),
        post.getCreatedAt()
    );
  }
}
