package com.apiece.springboot_sns.controller;

import com.apiece.springboot_sns.controller.dto.SignUpRequest;
import com.apiece.springboot_sns.controller.dto.UserResponse;
import com.apiece.springboot_sns.domain.user.User;
import com.apiece.springboot_sns.domain.user.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/api/users")
    public ResponseEntity<UserResponse> signUp(@Valid @RequestBody SignUpRequest request) {
        User user = userService.signUp(request.email(), request.password(), request.nickname());
        return ResponseEntity.status(HttpStatus.CREATED).body(UserResponse.from(user));
    }

    @GetMapping("/api/users/{id}")
    public ResponseEntity<UserResponse> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        return ResponseEntity.ok(UserResponse.from(user));
    }

    @GetMapping("/api/users/search")
    public ResponseEntity<UserResponse> getUserByEmail(@RequestParam String email) {
        User user = userService.findByEmail(email);
        return ResponseEntity.ok(UserResponse.from(user));
    }
}
