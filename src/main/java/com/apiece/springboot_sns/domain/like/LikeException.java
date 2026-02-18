package com.apiece.springboot_sns.domain.like;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class LikeException extends DomainException {

    public LikeException(String message, DomainErrorCode errorCode) {
        super(message, errorCode);
    }
}
