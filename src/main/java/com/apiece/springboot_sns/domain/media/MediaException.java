package com.apiece.springboot_sns.domain.media;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class MediaException extends DomainException {

    public MediaException(String message, DomainErrorCode errorCode) {
        super(message, errorCode);
    }
}
