package com.apiece.springboot_sns.controller.dto;

import com.apiece.springboot_sns.domain.user.User;

public record UserResponse(Long id, String email, String nickname) {

    public static UserResponse from(User user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getNickname());
    }
}
