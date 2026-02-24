package com.apiece.springboot_sns.domain.media;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "media")
public record MediaProperties(
    long singleUploadMaxSize,
    long partSize,
    Duration presignDuration
) {}
