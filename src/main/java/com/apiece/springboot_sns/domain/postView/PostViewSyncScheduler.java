package com.apiece.springboot_sns.domain.postView;

import java.util.Set;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class PostViewSyncScheduler {

  private final PostViewRepository postViewRepository;
  private final PostViewService postViewService;

  @Scheduled(fixedRateString = "${rustfs.view-sync-interval}")
  public void syncViewCountsToDb() {
    Set<String> dirtyPostIds = postViewRepository.getDirtyPostIds();
    if (dirtyPostIds == null || dirtyPostIds.isEmpty()) {
      return;
    }

    for (String postIdStr : dirtyPostIds) {
      try {
        postViewService.syncSinglePost(postIdStr);
      } catch (Exception e) {
        log.error("Failed to sync view count for postId={}", postIdStr, e);
      }
    }
  }
}
