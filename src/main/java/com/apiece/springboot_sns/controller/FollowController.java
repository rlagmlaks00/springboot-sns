package com.apiece.springboot_sns.controller;

import com.apiece.springboot_sns.config.AuthUser;
import com.apiece.springboot_sns.controller.dto.FollowCountResponse;
import com.apiece.springboot_sns.domain.follow.FollowCount;
import com.apiece.springboot_sns.domain.follow.FollowService;
import com.apiece.springboot_sns.domain.user.User;
import com.apiece.springboot_sns.domain.user.UserException;
import com.apiece.springboot_sns.domain.user.UserRepository;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.orm.ObjectOptimisticLockingFailureException;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class FollowController {

    private static final int MAX_RETRY = 3;

    private final FollowService followService;
    private final UserRepository userRepository;

    @PostMapping("/api/v1/follow/{userId}")
    public ResponseEntity<Map<String, String>> follow(
            @AuthUser User follower, @PathVariable Long userId) {
        User following = findUserById(userId);
        retryOnOptimisticLock(() -> followService.follow(follower, following));
        return ResponseEntity.ok(Map.of("message", "팔로우 성공"));
    }

    @DeleteMapping("/api/v1/follow/{userId}")
    public ResponseEntity<Map<String, String>> unfollow(
            @AuthUser User follower, @PathVariable Long userId) {
        User following = findUserById(userId);
        retryOnOptimisticLock(() -> followService.unfollow(follower, following));
        return ResponseEntity.ok(Map.of("message", "언팔로우 성공"));
    }

    @GetMapping("/api/v1/follow/count/{userId}")
    public ResponseEntity<FollowCountResponse> getFollowCount(@PathVariable Long userId) {
        User user = findUserById(userId);
        FollowCount followCount = followService.getFollowCount(user);
        return ResponseEntity.ok(FollowCountResponse.from(followCount));
    }

    private void retryOnOptimisticLock(Runnable action) {
        for (int attempt = 0; attempt < MAX_RETRY; attempt++) {
            try {
                action.run();
                return;
            } catch (ObjectOptimisticLockingFailureException e) {
                if (attempt == MAX_RETRY - 1) {
                    throw e;
                }
            }
        }
    }

    private User findUserById(Long userId) {
        return userRepository
                .findById(userId)
                .orElseThrow(() -> new UserException("존재하지 않는 사용자입니다."));
    }
}
