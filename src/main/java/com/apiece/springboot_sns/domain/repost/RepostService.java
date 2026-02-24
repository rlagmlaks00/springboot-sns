package com.apiece.springboot_sns.domain.repost;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostRepository;
import com.apiece.springboot_sns.domain.post.PostService;
import com.apiece.springboot_sns.domain.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class RepostService {

  private final PostRepository postRepository;
  private final PostService postService;

  public record RepostResult(Post repost, Post original) {}

  /** 리포스트 생성 */
  @Transactional
  public RepostResult createRepost(User user, Long repostId) {
    Post original = postService.getById(repostId);
    if (postRepository.existsByUserAndRepostId(user, original.getId())) {
      throw new RepostException("이미 리포스트한 게시글입니다.", DomainErrorCode.CONFLICT);
    }
    Post repost = postRepository.save(Post.createRepost(user, original.getId()));
    postRepository.incrementRepostCount(original.getId());
    return new RepostResult(repost, original);
  }

  /** 리포스트 삭제 */
  @Transactional
  public void deleteRepost(User user, Long repostId) {
    Post repost = postRepository.findByUserAndRepostId(user, repostId)
        .orElseThrow(() -> new RepostException("리포스트를 찾을 수 없습니다.", DomainErrorCode.NOT_FOUND));
    postRepository.delete(repost);
    postRepository.decrementRepostCount(repostId);
  }
}
