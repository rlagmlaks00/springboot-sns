package com.apiece.springboot_sns.domain.post;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class PostException extends DomainException {

    public PostException(String message, DomainErrorCode errorCode) {
        super(message, errorCode);
    }
}
