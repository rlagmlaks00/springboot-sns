package com.apiece.springboot_sns.domain.media;

public record UploadPartInfo(
    int partNumber,
    String eTag
) {}
