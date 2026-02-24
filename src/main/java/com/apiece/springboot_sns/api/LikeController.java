package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.like.LikeService;
import com.apiece.springboot_sns.domain.user.User;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class LikeController {

  private final LikeService likeService;

  /** 좋아요 */
  @PostMapping("/api/v1/likes/{postId}")
  public ResponseEntity<Map<String, String>> like(@AuthUser User user, @PathVariable Long postId) {
    likeService.like(user, postId);
    return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("message", "좋아요 성공"));
  }

  /** 좋아요 취소 */
  @DeleteMapping("/api/v1/likes/{postId}")
  public ResponseEntity<Void> unlike(@AuthUser User user, @PathVariable Long postId) {
    likeService.unlike(user, postId);
    return ResponseEntity.noContent().build();
  }

  /** 좋아요 여부 확인 */
  @GetMapping("/api/v1/likes/{postId}")
  public ResponseEntity<Map<String, Boolean>> isLiked(@AuthUser User user, @PathVariable Long postId) {
    boolean liked = likeService.isLiked(user, postId);
    return ResponseEntity.ok(Map.of("liked", liked));
  }
}
