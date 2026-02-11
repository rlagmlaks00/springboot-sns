package com.apiece.springboot_sns.api.dto.follow;

import com.apiece.springboot_sns.domain.follow.FollowCount;

public record FollowCountResponse(
        int followerCount,

        int followingCount
) {

    public static FollowCountResponse from(FollowCount followCount) {
        return new FollowCountResponse(
                followCount.getFollowerCount(),
                followCount.getFollowingCount()
        );
    }
}
