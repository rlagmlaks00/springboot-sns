package com.apiece.springboot_sns.domain.post;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import com.apiece.springboot_sns.domain.user.User;
import java.time.LocalDateTime;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final PostProperties postProperties;

    /** 게시글 생성 */
    public Post create(String content, User user) {
        return postRepository.save(Post.create(content, user));
    }

    /** 게시글 수정 (dirty checking) */
    @Transactional
    public Post update(Long postId, String content, User user) {
        Post post = getById(postId);
        if (post.getType() == PostType.REPOST) {
            throw new PostException("리포스트는 수정할 수 없습니다.", DomainErrorCode.BAD_REQUEST);
        }
        if (!post.getUser().getId().equals(user.getId())) {
            throw new PostException("게시글 수정 권한이 없습니다.", DomainErrorCode.FORBIDDEN);
        }
        if (post.isEditExpired(LocalDateTime.now(), postProperties.editWindow())) {
            throw new PostException("게시글 수정 가능 시간이 지났습니다.", DomainErrorCode.BAD_REQUEST);
        }
        post.updateContent(content);
        return post;
    }

    /** 게시글 삭제 */
    @Transactional
    public void delete(Long postId, User user) {
        Post post = getById(postId);
        if (!post.getUser().getId().equals(user.getId())) {
            throw new PostException("게시글 삭제 권한이 없습니다.", DomainErrorCode.FORBIDDEN);
        }
        postRepository.delete(post);
    }

    /** 게시글 단건 조회 */
    @Transactional(readOnly = true)
    public Post getById(Long postId) {
        return postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new PostException("게시글을 찾을 수 없습니다.", DomainErrorCode.NOT_FOUND));
    }

    /** 사용자별 게시글 목록 조회 */
    @Transactional(readOnly = true)
    public Page<Post> getPostsByUser(User user, Pageable pageable) {
        return postRepository.findByUserWithUser(user, pageable);
    }

    /** 좋아요 수 증가 */
    public void incrementLikeCount(Long postId) {
        postRepository.incrementLikeCount(postId);
    }

    /** 좋아요 수 감소 */
    public void decrementLikeCount(Long postId) {
        postRepository.decrementLikeCount(postId);
    }

    /** 원본 게시글 조회 (repost/quote의 원본) */
    @Transactional(readOnly = true)
    public Optional<Post> findOriginalPost(Post post) {
        if (post.getRepostId() != null) {
            return postRepository.findByIdWithUser(post.getRepostId());
        }
        if (post.getQuoteId() != null) {
            return postRepository.findByIdWithUser(post.getQuoteId());
        }
        return Optional.empty();
    }
}
