package com.apiece.springboot_sns.domain.user;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class UserException extends DomainException {

  public UserException(String message, DomainErrorCode errorCode) {
    super(message, errorCode);
  }
}
