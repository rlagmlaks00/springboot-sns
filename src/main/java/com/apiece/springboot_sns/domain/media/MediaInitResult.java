package com.apiece.springboot_sns.domain.media;

import java.util.List;

public record MediaInitResult(
    Media media,
    String presignedUrl,
    String uploadId,
    List<PresignedPart> presignedParts
) {

  public record PresignedPart(
      int partNumber,
      String presignedUrl
  ) {}
}
