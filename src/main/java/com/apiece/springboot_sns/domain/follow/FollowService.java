package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FollowService {

    private final FollowRepository followRepository;
    private final FollowCountService followCountService;

    @Transactional
    public void follow(User follower, User following) {
        if (follower.getId().equals(following.getId())) {
            throw new FollowException("자기 자신을 팔로우할 수 없습니다.");
        }
        if (followRepository.existsByFollowerAndFollowing(follower, following)) {
            throw new FollowException("이미 팔로우 중입니다.");
        }
        followRepository.save(new Follow(follower, following));
        followCountService.incrementCounts(follower, following);
    }

    @Transactional
    public void unfollow(User follower, User following) {
        Follow follow =
                followRepository
                        .findByFollowerAndFollowing(follower, following)
                        .orElseThrow(() -> new FollowException("팔로우 관계가 존재하지 않습니다."));
        followRepository.softDelete(follow.getId());
        followCountService.decrementCounts(follower, following);
    }

    public Page<Follow> getFollowers(User user, Pageable pageable) {
        return followRepository.findByFollowing(user, pageable);
    }

    public Page<Follow> getFollowings(User user, Pageable pageable) {
        return followRepository.findByFollower(user, pageable);
    }
}
