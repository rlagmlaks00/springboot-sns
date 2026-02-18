package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.domain.post.PostService;
import com.apiece.springboot_sns.domain.postView.PostViewService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class PostViewController {

    private final PostService postService;
    private final PostViewService postViewService;

    @PostMapping("/api/v1/posts/{postId}/view")
    public ResponseEntity<Void> view(@PathVariable Long postId) {
        postService.validateExists(postId);
        postViewService.incrementViewCount(postId);
        return ResponseEntity.ok().build();
    }
}
