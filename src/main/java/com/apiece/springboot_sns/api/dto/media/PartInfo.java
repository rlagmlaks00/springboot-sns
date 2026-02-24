package com.apiece.springboot_sns.api.dto.media;

import com.apiece.springboot_sns.domain.media.UploadPartInfo;

public record PartInfo(
    int partNumber,
    String eTag
) {

  public UploadPartInfo toEntity() {
    return new UploadPartInfo(partNumber, eTag);
  }
}
