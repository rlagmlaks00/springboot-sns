package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.post.PostResponse;
import com.apiece.springboot_sns.api.dto.repost.RepostCreateRequest;
import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.repost.RepostService;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class RepostController {

  private final RepostService repostService;

  /** 리포스트 생성 */
  @PostMapping("/api/v1/reposts")
  public ResponseEntity<PostResponse> createRepost(
      @AuthUser User user, @Valid @RequestBody RepostCreateRequest request) {
    RepostService.RepostResult result = repostService.createRepost(user, request.repostId());
    return ResponseEntity.status(HttpStatus.CREATED).body(PostResponse.from(result.repost(), result.original()));
  }

  /** 리포스트 삭제 */
  @DeleteMapping("/api/v1/reposts/{repostId}")
  public ResponseEntity<Void> deleteRepost(@AuthUser User user, @PathVariable Long repostId) {
    repostService.deleteRepost(user, repostId);
    return ResponseEntity.noContent().build();
  }
}
