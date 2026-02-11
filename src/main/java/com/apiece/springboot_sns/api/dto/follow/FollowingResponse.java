package com.apiece.springboot_sns.api.dto.follow;

import com.apiece.springboot_sns.domain.follow.Follow;
import com.apiece.springboot_sns.domain.user.User;
import java.time.LocalDateTime;

public record FollowingResponse(
        Long id,

        String email,

        String username,

        LocalDateTime followedAt
) {

    public static FollowingResponse from(Follow follow) {
        User following = follow.getFollowing();
        return new FollowingResponse(
                following.getId(),
                following.getEmail(),
                following.getUsername(),
                follow.getCreatedAt()
        );
    }
}
