package com.apiece.springboot_sns.api.dto.repost;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record RepostCreateRequest(
        @NotNull(message = "Repost post ID is required")
        @Positive(message = "Repost post ID must be positive")
        Long repostId
) {}
