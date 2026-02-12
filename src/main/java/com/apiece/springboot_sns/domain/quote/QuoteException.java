package com.apiece.springboot_sns.domain.quote;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class QuoteException extends DomainException {

    public QuoteException(String message, DomainErrorCode errorCode) {
        super(message, errorCode);
    }
}
