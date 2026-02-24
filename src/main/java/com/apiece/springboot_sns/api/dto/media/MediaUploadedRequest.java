package com.apiece.springboot_sns.api.dto.media;

import com.apiece.springboot_sns.domain.media.UploadPartInfo;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.util.List;

public record MediaUploadedRequest(
    @NotNull(message = "Media ID is required")
    Long mediaId,

    @Valid
    List<PartInfo> parts
) {

  public List<UploadPartInfo> toParts() {
    if (parts == null) return null;
    return parts.stream()
        .map(PartInfo::toEntity)
        .toList();
  }
}
