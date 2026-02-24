package com.apiece.springboot_sns.domain.repost;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.common.DomainException;

public class RepostException extends DomainException {

  public RepostException(String message, DomainErrorCode errorCode) {
    super(message, errorCode);
  }
}
