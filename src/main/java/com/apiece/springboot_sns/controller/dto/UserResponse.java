package com.apiece.springboot_sns.controller.dto;

import com.apiece.springboot_sns.config.CustomUserDetails;

public record UserResponse(Long id, String email, String username) {

    public static UserResponse from(CustomUserDetails userDetails) {
        return new UserResponse(
                userDetails.getId(), userDetails.getEmail(), userDetails.getDisplayName());
    }
}
