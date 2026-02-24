package com.apiece.springboot_sns.api.dto.post;

import com.apiece.springboot_sns.domain.post.PostConstants;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

public record PostCreateRequest(
    @NotBlank(message = "Content is required")
    @Size(max = PostConstants.MAX_CONTENT_LENGTH, message = "Content must be at most " + PostConstants.MAX_CONTENT_LENGTH + " characters")
    String content,

    @Size(max = PostConstants.MAX_MEDIA_COUNT, message = "미디어는 최대 " + PostConstants.MAX_MEDIA_COUNT + "개까지 첨부할 수 있습니다.")
    List<Long> mediaIds
) {}
