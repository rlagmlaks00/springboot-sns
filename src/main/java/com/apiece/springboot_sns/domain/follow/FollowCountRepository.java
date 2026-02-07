package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.user.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FollowCountRepository extends JpaRepository<FollowCount, Long> {

    Optional<FollowCount> findByUser(User user);
}
