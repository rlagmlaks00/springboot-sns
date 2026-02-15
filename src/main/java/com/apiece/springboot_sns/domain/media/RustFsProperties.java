package com.apiece.springboot_sns.domain.media;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "rustfs")
public record RustFsProperties(
        String endpoint,
        int consolePort,
        String accessKey,
        String secretKey,
        String bucket,
        String region
) {}
