package com.apiece.springboot_sns.api.dto.timeline;

import com.apiece.springboot_sns.api.dto.post.PostResponse;
import com.apiece.springboot_sns.domain.post.Post;
import java.time.ZoneOffset;
import java.util.List;

public record TimelineResponse(
    List<PostResponse> posts,

    Double nextCursor
) {

  public static TimelineResponse from(List<Post> posts) {
    List<PostResponse> postResponses = posts.stream()
        .map(PostResponse::from)
        .toList();

    Double nextCursor = posts.isEmpty()
        ? null
        : posts.get(posts.size() - 1).getCreatedAt().toEpochSecond(ZoneOffset.UTC) * 1.0;

    return new TimelineResponse(postResponses, nextCursor);
  }
}
