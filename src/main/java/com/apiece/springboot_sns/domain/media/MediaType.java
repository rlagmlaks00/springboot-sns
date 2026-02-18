package com.apiece.springboot_sns.domain.media;

public enum MediaType {
    IMAGE(".jpg"),
    VIDEO(".mp4");

    private final String extension;

    MediaType(String extension) {
        this.extension = extension;
    }

    public String getExtension() {
        return extension;
    }
}
