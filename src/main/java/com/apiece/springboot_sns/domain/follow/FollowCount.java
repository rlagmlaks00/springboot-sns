package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.common.BaseTimeEntity;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.persistence.Column;
import jakarta.persistence.ConstraintMode;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import jakarta.persistence.Version;
import lombok.Getter;

@Entity
@Table(
        name = "follow_counts",
        uniqueConstraints = @UniqueConstraint(columnNames = "user_id"))
@Getter
public class FollowCount extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "user_id",
            foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private User user;

    @Column(nullable = false)
    private int followerCount = 0;

    @Column(nullable = false)
    private int followingCount = 0;

    @Version
    private Long version;

    protected FollowCount() {}

    public FollowCount(User user) {
        this.user = user;
    }

    public void incrementFollower() {
        this.followerCount++;
    }

    public void decrementFollower() {
        this.followerCount--;
    }

    public void incrementFollowing() {
        this.followingCount++;
    }

    public void decrementFollowing() {
        this.followingCount--;
    }
}
