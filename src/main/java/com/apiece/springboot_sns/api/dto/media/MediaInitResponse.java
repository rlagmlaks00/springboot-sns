package com.apiece.springboot_sns.api.dto.media;

import com.apiece.springboot_sns.domain.media.MediaInitResult;
import com.apiece.springboot_sns.domain.media.MediaStatus;
import com.apiece.springboot_sns.domain.media.MediaType;
import java.util.List;

public record MediaInitResponse(
        Long id,
        MediaType mediaType,
        String path,
        MediaStatus status,
        String presignedUrl,
        String uploadId,
        List<PresignedUrlPart> presignedUrlParts
) {

    public static MediaInitResponse from(MediaInitResult result) {
        List<PresignedUrlPart> parts = null;
        if (result.presignedParts() != null) {
            parts =
                    result.presignedParts().stream()
                            .map(p -> new PresignedUrlPart(p.partNumber(), p.presignedUrl()))
                            .toList();
        }

        return new MediaInitResponse(
                result.media().getId(),
                result.media().getMediaType(),
                result.media().getPath(),
                result.media().getStatus(),
                result.presignedUrl(),
                result.uploadId(),
                parts);
    }
}
