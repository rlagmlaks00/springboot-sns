package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.follow.FollowCountResponse;
import com.apiece.springboot_sns.config.AuthUser;
import com.apiece.springboot_sns.domain.follow.FollowCount;
import com.apiece.springboot_sns.domain.follow.FollowCountService;
import com.apiece.springboot_sns.domain.user.User;
import com.apiece.springboot_sns.domain.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class FollowCountController {

    private final FollowCountService followCountService;
    private final UserService userService;

    @GetMapping("/api/v1/follow/count/me")
    public ResponseEntity<FollowCountResponse> getMyFollowCount(@AuthUser User user) {
        FollowCount followCount = followCountService.getFollowCount(user);
        return ResponseEntity.ok(FollowCountResponse.from(followCount));
    }

    @GetMapping("/api/v1/follow/count/{username}")
    public ResponseEntity<FollowCountResponse> getFollowCount(@PathVariable String username) {
        User user = userService.getByUsername(username);
        FollowCount followCount = followCountService.getFollowCount(user);
        return ResponseEntity.ok(FollowCountResponse.from(followCount));
    }
}
