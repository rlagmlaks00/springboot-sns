package com.apiece.springboot_sns.api.dto.media;

import com.apiece.springboot_sns.domain.media.MediaType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record MediaInitRequest(
        @NotNull(message = "Media type is required")
        MediaType mediaType,

        @NotNull(message = "File size is required")
        @Min(value = 1, message = "File size must be positive")
        Long fileSize
) {}
