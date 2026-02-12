package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.post.PostResponse;
import com.apiece.springboot_sns.api.dto.post.PostCreateRequest;
import com.apiece.springboot_sns.api.dto.post.PostUpdateRequest;
import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostService;
import com.apiece.springboot_sns.domain.user.User;
import com.apiece.springboot_sns.domain.user.UserService;
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
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;
    private final UserService userService;

    /** 게시글 생성 */
    @PostMapping("/api/v1/posts")
    public ResponseEntity<PostResponse> create(
            @AuthUser User user, @Valid @RequestBody PostCreateRequest request) {
        Post post = postService.create(request.content(), user);
        return ResponseEntity.status(HttpStatus.CREATED).body(PostResponse.from(post));
    }

    /** 게시글 수정 */
    @PatchMapping("/api/v1/posts/{postId}")
    public ResponseEntity<PostResponse> update(
            @AuthUser User user,
            @PathVariable Long postId,
            @Valid @RequestBody PostUpdateRequest request) {
        Post post = postService.update(postId, request.content(), user);
        return ResponseEntity.ok(PostResponse.from(post));
    }

    /** 게시글 삭제 */
    @DeleteMapping("/api/v1/posts/{postId}")
    public ResponseEntity<Void> delete(@AuthUser User user, @PathVariable Long postId) {
        postService.delete(postId, user);
        return ResponseEntity.noContent().build();
    }

    /** 게시글 단건 조회 */
    @GetMapping("/api/v1/posts/{postId}")
    public ResponseEntity<PostResponse> getById(@PathVariable Long postId) {
        Post post = postService.getById(postId);
        return ResponseEntity.ok(toResponse(post));
    }

    /** 사용자별 게시글 목록 조회 */
    @GetMapping("/api/v1/posts/user/{username}")
    public ResponseEntity<Page<PostResponse>> getPostsByUser(
            @PathVariable String username,
            @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        User user = userService.getByUsername(username);
        Page<PostResponse> posts =
                postService.getPostsByUser(user, pageable).map(this::toResponse);
        return ResponseEntity.ok(posts);
    }

    private PostResponse toResponse(Post post) {
        Post original = postService.findOriginalPost(post).orElse(null);
        if (original != null) {
            return PostResponse.from(post, original);
        }
        return PostResponse.from(post);
    }
}
