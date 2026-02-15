package com.apiece.springboot_sns.api.dto.media;

import jakarta.validation.constraints.NotNull;
import java.util.List;

public record MediaUploadedRequest(
        @NotNull(message = "Media ID is required")
        Long mediaId,

        List<PartInfo> parts
) {}
