package com.apiece.springboot_sns.domain.common;

import lombok.Getter;

@Getter
public abstract class DomainException extends RuntimeException {

    private final DomainErrorCode errorCode;

    protected DomainException(String message, DomainErrorCode errorCode) {
        super(message);
        this.errorCode = errorCode;
    }
}
