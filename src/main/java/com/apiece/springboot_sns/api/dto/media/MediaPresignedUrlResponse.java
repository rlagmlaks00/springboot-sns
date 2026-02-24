package com.apiece.springboot_sns.api.dto.media;

public record MediaPresignedUrlResponse(
    Long mediaId,
    String presignedUrl
) {

  public static MediaPresignedUrlResponse from(Long mediaId, String presignedUrl) {
    return new MediaPresignedUrlResponse(mediaId, presignedUrl);
  }
}
