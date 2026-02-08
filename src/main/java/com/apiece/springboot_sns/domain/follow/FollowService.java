package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class FollowService {

    private final FollowRepository followRepository;
    private final FollowCountRepository followCountRepository;

    public FollowService(
            FollowRepository followRepository, FollowCountRepository followCountRepository) {
        this.followRepository = followRepository;
        this.followCountRepository = followCountRepository;
    }

    @Transactional
    public void follow(User follower, User following) {
        if (follower.getId().equals(following.getId())) {
            throw new FollowException("자기 자신을 팔로우할 수 없습니다.");
        }
        if (followRepository.existsByFollowerAndFollowing(follower, following)) {
            throw new FollowException("이미 팔로우 중입니다.");
        }
        followRepository.save(new Follow(follower, following));

        getOrCreateFollowCount(follower).incrementFollowing();
        getOrCreateFollowCount(following).incrementFollower();
    }

    @Transactional
    public void unfollow(User follower, User following) {
        Follow follow =
                followRepository
                        .findByFollowerAndFollowing(follower, following)
                        .orElseThrow(() -> new FollowException("팔로우 관계가 존재하지 않습니다."));
        followRepository.delete(follow);

        getOrCreateFollowCount(follower).decrementFollowing();
        getOrCreateFollowCount(following).decrementFollower();
    }

    @Transactional(readOnly = true)
    public FollowCount getFollowCount(User user) {
        return followCountRepository
                .findByUser(user)
                .orElseGet(() -> new FollowCount(user));
    }

    private FollowCount getOrCreateFollowCount(User user) {
        return followCountRepository
                .findByUser(user)
                .orElseGet(() -> createFollowCount(user));
    }

    private FollowCount createFollowCount(User user) {
        try {
            return followCountRepository.saveAndFlush(new FollowCount(user));
        } catch (DataIntegrityViolationException e) {
            return followCountRepository
                    .findByUser(user)
                    .orElseThrow(() -> new FollowException("팔로우 카운트 생성에 실패했습니다."));
        }
    }
}
