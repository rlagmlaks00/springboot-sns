package com.apiece.springboot_sns.api.dto.media;

public record PresignedUrlPart(
        int partNumber,
        String presignedUrl
) {}
