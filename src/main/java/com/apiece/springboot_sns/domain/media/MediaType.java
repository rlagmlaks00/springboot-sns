package com.apiece.springboot_sns.domain.media;

import lombok.Getter;

@Getter
public enum MediaType {
  IMAGE(".jpg"),
  VIDEO(".mp4");

  private final String extension;

  MediaType(String extension) {
    this.extension = extension;
  }

}
