package com.apiece.springboot_sns.domain.post;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "post")
public record PostProperties(
        Duration editWindow
) {}
