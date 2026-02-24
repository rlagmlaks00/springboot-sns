package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.post.PostResponse;
import com.apiece.springboot_sns.api.dto.quote.QuoteCreateRequest;
import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.quote.QuoteService;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class QuoteController {

  private final QuoteService quoteService;

  /** 인용 게시글 생성 */
  @PostMapping("/api/v1/quotes")
  public ResponseEntity<PostResponse> createQuote(
      @AuthUser User user, @Valid @RequestBody QuoteCreateRequest request) {
    QuoteService.QuoteResult result = quoteService.createQuote(request.content(), user, request.quoteId());
    return ResponseEntity.status(HttpStatus.CREATED).body(PostResponse.from(result.quote(), result.original()));
  }

  /** 인용 게시글 목록 조회 */
  @GetMapping("/api/v1/posts/{postId}/quotes")
  public ResponseEntity<Page<PostResponse>> getQuotes(
      @PathVariable Long postId,
      @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
    Page<PostResponse> quotes = quoteService.getQuotes(postId, pageable).map(PostResponse::from);
    return ResponseEntity.ok(quotes);
  }

  /** 인용 게시글 삭제 */
  @DeleteMapping("/api/v1/quotes/{quoteId}")
  public ResponseEntity<Void> deleteQuote(@AuthUser User user, @PathVariable Long quoteId) {
    quoteService.deleteQuote(user, quoteId);
    return ResponseEntity.noContent().build();
  }
}
