package com.apiece.springboot_sns.api;

import com.apiece.springboot_sns.api.dto.media.MediaInitRequest;
import com.apiece.springboot_sns.api.dto.media.MediaInitResponse;
import com.apiece.springboot_sns.api.dto.media.MediaPresignedUrlResponse;
import com.apiece.springboot_sns.api.dto.media.MediaUploadedRequest;
import com.apiece.springboot_sns.config.auth.AuthUser;
import com.apiece.springboot_sns.domain.media.MediaInitResult;
import com.apiece.springboot_sns.domain.media.MediaService;
import com.apiece.springboot_sns.domain.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class MediaController {

  private final MediaService mediaService;

  @PostMapping("/api/v1/media/init")
  public ResponseEntity<MediaInitResponse> initUpload(
      @AuthUser User user, @Valid @RequestBody MediaInitRequest request) {
    MediaInitResult result =
        mediaService.initUpload(request.mediaType(), request.fileSize(), user.getId());
    return ResponseEntity.status(HttpStatus.CREATED).body(MediaInitResponse.from(result));
  }

  @GetMapping("/api/v1/media/{id}/presigned-url")
  public ResponseEntity<MediaPresignedUrlResponse> getPresignedUrl(
      @AuthUser User user, @PathVariable Long id) {
    String presignedUrl = mediaService.getPresignedUrl(id, user.getId());
    return ResponseEntity.ok(MediaPresignedUrlResponse.from(id, presignedUrl));
  }

  @PostMapping("/api/v1/media/uploaded")
  public ResponseEntity<Void> markUploaded(
      @AuthUser User user, @Valid @RequestBody MediaUploadedRequest request) {
    mediaService.markUploaded(request.mediaId(), request.toParts(), user.getId());
    return ResponseEntity.noContent().build();
  }
}
