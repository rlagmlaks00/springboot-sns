package com.apiece.springboot_sns.domain.timeline;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.timeline")
public record TimelineProperties(
    int maxTimelineSize,
    int celebFollowerThreshold
) {}
