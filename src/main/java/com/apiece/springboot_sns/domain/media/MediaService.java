package com.apiece.springboot_sns.domain.media;

import com.apiece.springboot_sns.domain.common.DomainErrorCode;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CompletedMultipartUpload;
import software.amazon.awssdk.services.s3.model.CompletedPart;
import software.amazon.awssdk.services.s3.model.CompleteMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.CreateMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.CreateMultipartUploadResponse;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.UploadPartRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.GetObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedGetObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PresignedUploadPartRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;
import software.amazon.awssdk.services.s3.presigner.model.UploadPartPresignRequest;

@Slf4j
@Service
@RequiredArgsConstructor
public class MediaService {

  private final MediaRepository mediaRepository;
  private final S3Client s3Client;
  private final S3Presigner s3Presigner;
  private final RustFsProperties rustFsProperties;
  private final MediaProperties mediaProperties;

  @Transactional
  public MediaInitResult initUpload(MediaType mediaType, long fileSize, Long userId) {
    String path = generatePath(userId, mediaType);
    Media media = Media.create(mediaType, path, userId);

    if (fileSize <= mediaProperties.singleUploadMaxSize()) {
      media = mediaRepository.save(media);
      String presignedUrl = generatePresignedPutUrl(path);
      return new MediaInitResult(media, presignedUrl, null, null);
    }

    // Multipart upload
    String uploadId = createMultipartUpload(path);
    media.assignUploadId(uploadId);
    media = mediaRepository.save(media);

    int partCount = (int) Math.ceil((double) fileSize / mediaProperties.partSize());
    List<MediaInitResult.PresignedPart> parts = new ArrayList<>();
    for (int i = 1; i <= partCount; i++) {
      String partUrl = generatePresignedUploadPartUrl(path, uploadId, i);
      parts.add(new MediaInitResult.PresignedPart(i, partUrl));
    }

    return new MediaInitResult(media, null, uploadId, parts);
  }

  @Transactional
  public void markUploaded(Long mediaId, List<UploadPartInfo> parts, Long userId) {
    Media media =
        mediaRepository
            .findById(mediaId)
            .orElseThrow(
                () ->
                    new MediaException(
                        "Media not found", DomainErrorCode.NOT_FOUND));

    if (!media.getUserId().equals(userId)) {
      throw new MediaException(
          "Media does not belong to user", DomainErrorCode.FORBIDDEN);
    }

    try {
      if (parts == null || parts.isEmpty()) {
        media.markUploaded();
        media.markCompleted();
      } else {
        completeMultipartUpload(media.getPath(), media.getUploadId(), parts);
        media.markUploaded();
        media.markCompleted();
      }
    } catch (Exception e) {
      log.error("Failed to complete upload for media {}", mediaId, e);
      media.markFailed();
      throw new MediaException("Failed to complete upload", DomainErrorCode.BAD_REQUEST);
    }
  }

  public String getPresignedUrl(Long mediaId, Long userId) {
    Media media =
        mediaRepository
            .findById(mediaId)
            .orElseThrow(
                () -> new MediaException("Media not found", DomainErrorCode.NOT_FOUND));

    if (!media.getUserId().equals(userId)) {
      throw new MediaException("Media does not belong to user", DomainErrorCode.FORBIDDEN);
    }

    if (media.getStatus() != MediaStatus.COMPLETED) {
      throw new MediaException("Media is not completed", DomainErrorCode.BAD_REQUEST);
    }

    return generatePresignedGetUrl(media.getPath());
  }

  private String generatePresignedGetUrl(String path) {
    GetObjectPresignRequest presignRequest =
        GetObjectPresignRequest.builder()
            .signatureDuration(mediaProperties.presignDuration())
            .getObjectRequest(
                GetObjectRequest.builder()
                    .bucket(rustFsProperties.bucket())
                    .key(path)
                    .build())
            .build();

    PresignedGetObjectRequest presignedRequest = s3Presigner.presignGetObject(presignRequest);
    return presignedRequest.url().toString();
  }

  private String generatePath(Long userId, MediaType mediaType) {
    return "users/" + userId + "/" + UUID.randomUUID() + mediaType.getExtension();
  }

  private String generatePresignedPutUrl(String path) {
    PutObjectPresignRequest presignRequest =
        PutObjectPresignRequest.builder()
            .signatureDuration(mediaProperties.presignDuration())
            .putObjectRequest(
                PutObjectRequest.builder()
                    .bucket(rustFsProperties.bucket())
                    .key(path)
                    .build())
            .build();

    PresignedPutObjectRequest presignedRequest =
        s3Presigner.presignPutObject(presignRequest);
    return presignedRequest.url().toString();
  }

  private String createMultipartUpload(String path) {
    CreateMultipartUploadRequest request =
        CreateMultipartUploadRequest.builder()
            .bucket(rustFsProperties.bucket())
            .key(path)
            .build();

    CreateMultipartUploadResponse response = s3Client.createMultipartUpload(request);
    return response.uploadId();
  }

  private String generatePresignedUploadPartUrl(String path, String uploadId, int partNumber) {
    UploadPartPresignRequest presignRequest =
        UploadPartPresignRequest.builder()
            .signatureDuration(mediaProperties.presignDuration())
            .uploadPartRequest(
                UploadPartRequest.builder()
                    .bucket(rustFsProperties.bucket())
                    .key(path)
                    .uploadId(uploadId)
                    .partNumber(partNumber)
                    .build())
            .build();

    PresignedUploadPartRequest presignedRequest =
        s3Presigner.presignUploadPart(presignRequest);
    return presignedRequest.url().toString();
  }

  private void completeMultipartUpload(
      String path, String uploadId, List<UploadPartInfo> parts) {
    List<CompletedPart> completedParts =
        parts.stream()
            .map(
                part ->
                    CompletedPart.builder()
                        .partNumber(part.partNumber())
                        .eTag(part.eTag())
                        .build())
            .toList();

    CompleteMultipartUploadRequest request =
        CompleteMultipartUploadRequest.builder()
            .bucket(rustFsProperties.bucket())
            .key(path)
            .uploadId(uploadId)
            .multipartUpload(
                CompletedMultipartUpload.builder()
                    .parts(completedParts)
                    .build())
            .build();

    s3Client.completeMultipartUpload(request);
  }
}
