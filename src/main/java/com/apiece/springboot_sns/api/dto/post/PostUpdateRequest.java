package com.apiece.springboot_sns.api.dto.post;

import com.apiece.springboot_sns.domain.post.PostConstants;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record PostUpdateRequest(
    @NotBlank(message = "Content is required")
    @Size(max = PostConstants.MAX_CONTENT_LENGTH, message = "Content must be at most 1000 characters")
    String content
) {}
