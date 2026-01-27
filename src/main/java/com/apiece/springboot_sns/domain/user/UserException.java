package com.apiece.springboot_sns.domain.user;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class UserException extends RuntimeException {

    private final HttpStatus status;

    public UserException(String message, HttpStatus status) {
        super(message);
        this.status = status;
    }

    public static UserException emailAlreadyExists() {
        return new UserException("이미 존재하는 이메일입니다.", HttpStatus.BAD_REQUEST);
    }

    public static UserException notFound() {
        return new UserException("사용자를 찾을 수 없습니다.", HttpStatus.NOT_FOUND);
    }
}
