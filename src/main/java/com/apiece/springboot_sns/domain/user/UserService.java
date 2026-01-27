package com.apiece.springboot_sns.domain.user;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public User signUp(String email, String password, String nickname) {
        if (userRepository.existsByEmail(email)) {
            throw UserException.emailAlreadyExists();
        }
        String encodedPassword = passwordEncoder.encode(password);
        User user = new User(email, encodedPassword, nickname);
        return userRepository.save(user);
    }

    public User findById(Long id) {
        return userRepository.findById(id).orElseThrow(UserException::notFound);
    }

    public User findByEmail(String email) {
        return userRepository.findByEmail(email).orElseThrow(UserException::notFound);
    }
}
