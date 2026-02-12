package com.apiece.springboot_sns.domain.reply;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class ReplyException extends DomainException {

    public ReplyException(String message, DomainErrorCode errorCode) {
        super(message, errorCode);
    }
}
