package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class FollowCountService {

    private final FollowCountRepository followCountRepository;

    public FollowCount getFollowCount(User user) {
        return followCountRepository
                .findByUser(user)
                .orElseGet(() -> new FollowCount(user));
    }

    @Transactional
    public void incrementCounts(User follower, User following) {
        ensureFollowCountExists(follower);
        ensureFollowCountExists(following);
        followCountRepository.incrementFollowingCount(follower);
        followCountRepository.incrementFollowerCount(following);
    }

    @Transactional
    public void decrementCounts(User follower, User following) {
        ensureFollowCountExists(follower);
        ensureFollowCountExists(following);
        followCountRepository.decrementFollowingCount(follower);
        followCountRepository.decrementFollowerCount(following);
    }

    private void ensureFollowCountExists(User user) {
        if (followCountRepository.findByUser(user).isEmpty()) {
            createFollowCount(user);
        }
    }

    private void createFollowCount(User user) {
        try {
            followCountRepository.saveAndFlush(new FollowCount(user));
        } catch (DataIntegrityViolationException ignored) {
        }
    }
}
