package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.post.PostResponse;
import com.apiece.springboot_sns.api.dto.reply.ReplyCreateRequest;
import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.reply.ReplyService;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ReplyController {

    private final ReplyService replyService;

    /** 댓글 생성 */
    @PostMapping("/api/v1/replies")
    public ResponseEntity<PostResponse> createReply(
            @AuthUser User user, @Valid @RequestBody ReplyCreateRequest request) {
        Post post = replyService.createReply(request.content(), user, request.parentId());
        return ResponseEntity.status(HttpStatus.CREATED).body(PostResponse.from(post));
    }

    /** 댓글 목록 조회 */
    @GetMapping("/api/v1/posts/{postId}/replies")
    public ResponseEntity<Page<PostResponse>> getReplies(
            @PathVariable Long postId,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        Page<PostResponse> replies = replyService.getReplies(postId, pageable).map(PostResponse::from);
        return ResponseEntity.ok(replies);
    }
}
