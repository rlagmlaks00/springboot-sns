package com.apiece.springboot_sns.controller.dto;

import com.apiece.springboot_sns.config.CustomUserDetails;
import com.apiece.springboot_sns.domain.user.User;

public record UserResponse(Long id, String email, String username) {

    public static UserResponse from(CustomUserDetails userDetails) {
        return new UserResponse(
                userDetails.getId(), userDetails.getEmail(), userDetails.getDisplayName());
    }

    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getUsername());
    }
}
