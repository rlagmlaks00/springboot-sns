package com.apiece.springboot_sns.domain.reply;

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
public class ReplyService {

    private final PostRepository postRepository;
    private final PostService postService;

    /** 댓글 생성 */
    @Transactional
    public Post createReply(String content, User user, Long parentId) {
        postService.validateExists(parentId);
        Post reply = postRepository.save(Post.createReply(content, user, parentId));
        postRepository.incrementReplyCount(parentId);
        return reply;
    }

    /** 댓글 삭제 */
    @Transactional
    public void deleteReply(User user, Long replyId) {
        Post reply = postRepository.findByIdWithUser(replyId)
                .orElseThrow(() -> new ReplyException("댓글을 찾을 수 없습니다.", DomainErrorCode.NOT_FOUND));
        if (!reply.getUser().getId().equals(user.getId())) {
            throw new ReplyException("댓글 삭제 권한이 없습니다.", DomainErrorCode.FORBIDDEN);
        }
        postRepository.delete(reply);
        postRepository.decrementReplyCount(reply.getParentId());
    }

    /** 댓글 목록 조회 */
    @Transactional(readOnly = true)
    public Page<Post> getReplies(Long parentId, Pageable pageable) {
        return postRepository.findRepliesByParentId(parentId, pageable);
    }
}
