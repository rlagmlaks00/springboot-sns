package com.apiece.springboot_sns.domain.like;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.post.Post;
import com.apiece.springboot_sns.domain.post.PostService;
import com.apiece.springboot_sns.domain.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class LikeService {

    private final LikeRepository likeRepository;
    private final PostService postService;

    /** 좋아요 */
    @Transactional
    public void like(User user, Long postId) {
        Post post = postService.getById(postId);
        if (likeRepository.existsByUserAndPost(user, post)) {
            throw new LikeException("이미 좋아요한 게시글입니다.", DomainErrorCode.CONFLICT);
        }
        likeRepository.save(new Like(user, post));
        postService.incrementLikeCount(post.getId());
    }

    /** 좋아요 여부 확인 */
    public boolean isLiked(User user, Long postId) {
        return likeRepository.existsByUserIdAndPostId(user.getId(), postId);
    }

    /** 좋아요 취소 */
    @Transactional
    public void unlike(User user, Long postId) {
        Post post = postService.getById(postId);
        Like like = likeRepository.findByUserAndPost(user, post)
                .orElseThrow(() -> new LikeException("좋아요를 찾을 수 없습니다.", DomainErrorCode.NOT_FOUND));
        likeRepository.delete(like);
        postService.decrementLikeCount(post.getId());
    }
}
