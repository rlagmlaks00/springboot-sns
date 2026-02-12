package com.apiece.springboot_sns.api.dto.user;

import com.apiece.springboot_sns.domain.user.User;

public record UserResponse(Long id, String email, String username) {

    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getUsername());
    }
}
