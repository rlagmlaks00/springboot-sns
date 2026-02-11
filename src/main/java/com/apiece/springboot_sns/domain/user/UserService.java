package com.apiece.springboot_sns.domain.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User getByUsername(String username) {
        return userRepository
                .findByUsername(username)
                .orElseThrow(() -> new UserException("User not found: " + username));
    }

    public User signup(String email, String password, String username) {
        if (userRepository.existsByEmail(email)) {
            throw new UserException("Email already exists: " + email);
        }
        if (userRepository.existsByUsername(username)) {
            throw new UserException("Username already exists: " + username);
        }

        String encodedPassword = passwordEncoder.encode(password);
        User user = new User(email, encodedPassword, username);

        return userRepository.save(user);
    }
}
