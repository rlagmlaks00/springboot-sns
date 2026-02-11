package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.config.AuthUser;
import com.apiece.springboot_sns.api.dto.user.SignupRequest;
import com.apiece.springboot_sns.api.dto.user.SignupResponse;
import com.apiece.springboot_sns.api.dto.user.UserResponse;
import com.apiece.springboot_sns.domain.user.User;
import com.apiece.springboot_sns.domain.user.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/api/v1/signup")
    public ResponseEntity<SignupResponse> signup(@Valid @RequestBody SignupRequest request) {
        User user = userService.signup(request.email(), request.password(), request.username());
        return ResponseEntity.status(HttpStatus.CREATED).body(SignupResponse.from(user));
    }

    @GetMapping("/api/v1/me")
    public ResponseEntity<UserResponse> me(@AuthUser User user) {
        return ResponseEntity.ok(UserResponse.from(user));
    }
}
