package com.apiece.springboot_sns.domain.user;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /** 사용자 조회 (username) */
    public User getByUsername(String username) {
        return userRepository
                .findByUsername(username)
                .orElseThrow(() -> new UserException("User not found: " + username, DomainErrorCode.NOT_FOUND));
    }

    /** 회원 가입 */
    public User signup(String email, String password, String username) {
        if (userRepository.existsByEmail(email)) {
            throw new UserException("Email already exists: " + email, DomainErrorCode.CONFLICT);
        }
        if (userRepository.existsByUsername(username)) {
            throw new UserException("Username already exists: " + username, DomainErrorCode.CONFLICT);
        }

        String encodedPassword = passwordEncoder.encode(password);
        User user = new User(email, encodedPassword, username);

        return userRepository.save(user);
    }
}
