package com.apiece.springboot_sns.domain.media;

import com.apiece.springboot_sns.domain.common.BaseTimeEntity;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.SQLDelete;
import org.hibernate.annotations.SQLRestriction;
import org.hibernate.type.SqlTypes;

import java.util.HashMap;
import java.util.Map;

@Entity
@Table(name = "media")
@SQLDelete(sql = "UPDATE media SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?")
@SQLRestriction("deleted_at IS NULL")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Media extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MediaType mediaType;

    @Column(nullable = false)
    private String path;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MediaStatus status;

    @Column(nullable = false)
    private Long userId;

    private String uploadId;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(columnDefinition = "jsonb")
    private Map<String, Object> attributes = new HashMap<>();

    public static Media create(MediaType mediaType, String path, Long userId) {
        Media media = new Media();
        media.mediaType = mediaType;
        media.path = path;
        media.status = MediaStatus.INIT;
        media.userId = userId;
        return media;
    }

    public void markUploaded() {
        this.status = MediaStatus.UPLOADED;
    }

    public void markCompleted() {
        this.status = MediaStatus.COMPLETED;
    }

    public void markFailed() {
        this.status = MediaStatus.FAILED;
    }

    public void assignUploadId(String uploadId) {
        this.uploadId = uploadId;
    }
}
