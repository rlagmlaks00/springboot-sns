package com.apiece.springboot_sns.controller.dto;

import com.apiece.springboot_sns.domain.follow.Follow;
import com.apiece.springboot_sns.domain.user.User;
import java.time.LocalDateTime;

public record FollowerResponse(
        Long id,

        String email,

        String username,

        LocalDateTime followedAt
) {

    public static FollowerResponse from(Follow follow) {
        User follower = follow.getFollower();
        return new FollowerResponse(
                follower.getId(),
                follower.getEmail(),
                follower.getUsername(),
                follow.getCreatedAt()
        );
    }
}
