package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.config.AuthUser;
import com.apiece.springboot_sns.api.dto.follow.FollowerResponse;
import com.apiece.springboot_sns.api.dto.follow.FollowingResponse;
import com.apiece.springboot_sns.domain.follow.FollowService;
import com.apiece.springboot_sns.domain.user.User;
import com.apiece.springboot_sns.domain.user.UserService;
import java.util.Map;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class FollowController {

    private final FollowService followService;
    private final UserService userService;

    @PostMapping("/api/v1/follow/{username}")
    public ResponseEntity<Map<String, String>> follow(
            @AuthUser User follower, @PathVariable String username) {
        User following = userService.getByUsername(username);
        followService.follow(follower, following);
        return ResponseEntity.ok(Map.of("message", "팔로우 성공"));
    }

    @DeleteMapping("/api/v1/follow/{username}")
    public ResponseEntity<Map<String, String>> unfollow(
            @AuthUser User follower, @PathVariable String username) {
        User following = userService.getByUsername(username);
        followService.unfollow(follower, following);
        return ResponseEntity.ok(Map.of("message", "언팔로우 성공"));
    }

    @GetMapping("/api/v1/follow/followers/{username}")
    public ResponseEntity<Page<FollowerResponse>> getFollowers(
            @PathVariable String username, Pageable pageable) {
        User user = userService.getByUsername(username);
        Page<FollowerResponse> followers =
                followService.getFollowers(user, pageable).map(FollowerResponse::from);
        return ResponseEntity.ok(followers);
    }

    @GetMapping("/api/v1/follow/followings/{username}")
    public ResponseEntity<Page<FollowingResponse>> getFollowings(
            @PathVariable String username, Pageable pageable) {
        User user = userService.getByUsername(username);
        Page<FollowingResponse> followings =
                followService.getFollowings(user, pageable).map(FollowingResponse::from);
        return ResponseEntity.ok(followings);
    }
}
