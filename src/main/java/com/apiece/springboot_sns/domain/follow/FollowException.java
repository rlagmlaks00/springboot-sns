package com.apiece.springboot_sns.domain.follow;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class FollowException extends DomainException {

  public FollowException(String message, DomainErrorCode errorCode) {
    super(message, errorCode);
  }
}
