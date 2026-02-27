package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.timeline.TimelineResponse;
import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.timeline.TimelineService;
import com.apiece.springboot_sns.domain.user.User;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class TimelineController {

  private final TimelineService timelineService;

  /** 타임라인 조회 */
  @GetMapping("/api/v1/timeline")
  public ResponseEntity<TimelineResponse> getTimeline(
      @AuthUser User user,
      @RequestParam(required = false) Double cursor,
      @RequestParam(defaultValue = "20") int size) {
    List<Post> posts = timelineService.getTimeline(user, cursor, size);
    return ResponseEntity.ok(TimelineResponse.from(posts));
  }
}
