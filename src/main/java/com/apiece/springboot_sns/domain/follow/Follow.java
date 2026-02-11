package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.common.BaseTimeEntity;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.persistence.ConstraintMode;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.ForeignKey;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;

@Entity
@Table(name = "follows")
@SQLDelete(sql = "UPDATE follows SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Follow extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "follower_id",
            foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private User follower;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "following_id",
            foreignKey = @ForeignKey(ConstraintMode.NO_CONSTRAINT))
    private User following;

    public Follow(User follower, User following) {
        this.follower = follower;
        this.following = following;
    }
}
