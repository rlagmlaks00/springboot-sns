package com.apiece.springboot_sns.api.dto.user;

import com.apiece.springboot_sns.domain.user.User;

public record SignupResponse(Long id, String email, String username) {

  public static SignupResponse from(User user) {
    return new SignupResponse(user.getId(), user.getEmail(), user.getUsername());
  }
}
