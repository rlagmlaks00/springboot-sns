package com.apiece.springboot_sns.domain.quote;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostRepository;
import com.apiece.springboot_sns.domain.post.PostService;
import com.apiece.springboot_sns.domain.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class QuoteService {

  private final PostRepository postRepository;
  private final PostService postService;

  public record QuoteResult(Post quote, Post original) {}

  /** 인용 게시글 생성 */
  @Transactional
  public QuoteResult createQuote(String content, User user, Long quoteId) {
    Post quoted = postService.getById(quoteId);
    if (postRepository.existsByUserAndQuoteId(user, quoted.getId())) {
      throw new QuoteException("이미 인용한 게시글입니다.", DomainErrorCode.CONFLICT);
    }
    Post quote = postRepository.save(Post.createQuote(content, user, quoted.getId()));
    postRepository.incrementRepostCount(quoted.getId());
    return new QuoteResult(quote, quoted);
  }

  /** 인용 게시글 목록 조회 */
  @Transactional(readOnly = true)
  public Page<Post> getQuotes(Long quoteId, Pageable pageable) {
    return postRepository.findQuotesByQuoteId(quoteId, pageable);
  }

  /** 인용 게시글 삭제 */
  @Transactional
  public void deleteQuote(User user, Long quoteId) {
    Post quote = postRepository.findByUserAndQuoteId(user, quoteId)
        .orElseThrow(() -> new QuoteException("인용 게시글을 찾을 수 없습니다.", DomainErrorCode.NOT_FOUND));
    postRepository.delete(quote);
    postRepository.decrementRepostCount(quoteId);
  }
}
