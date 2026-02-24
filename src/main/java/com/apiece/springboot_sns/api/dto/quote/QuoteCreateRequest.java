package com.apiece.springboot_sns.api.dto.quote;

import com.apiece.springboot_sns.domain.post.PostConstants;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record QuoteCreateRequest(
    @NotBlank(message = "Content is required")
    @Size(max = PostConstants.MAX_CONTENT_LENGTH, message = "Content must be at most 1000 characters")
    String content,

    @NotNull(message = "Quote post ID is required")
    @Positive(message = "Quote post ID must be positive")
    Long quoteId
) {}
