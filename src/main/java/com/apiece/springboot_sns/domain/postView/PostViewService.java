package com.apiece.springboot_sns.domain.postView;

import com.apiece.springboot_sns.domain.post.PostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PostViewService {

  private final PostViewRepository postViewRepository;
  private final PostRepository postRepository;

  public void incrementViewCount(Long postId) {
    postViewRepository.increment(postId);
  }

  @Transactional
  public void syncSinglePost(String postIdStr) {
    Long postId = Long.valueOf(postIdStr);
    long count = postViewRepository.getAndResetCount(postId);

    if (count > 0) {
      postRepository.incrementViewCount(postId, count);
      postViewRepository.removeDirty(postIdStr);
    }
  }
}
