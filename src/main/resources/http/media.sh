#!/bin/bash

# 스크립트가 위치한 디렉토리 기준으로 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASE_URL="http://localhost:8080"
COOKIES="$SCRIPT_DIR/media/cookies.txt"
USER="TestUser4"
IMAGE_FILE="$SCRIPT_DIR/media/sample.png"
VIDEO_FILE="$SCRIPT_DIR/media/sample.mp4"
PART_SIZE=8388608    # 8MB (서버 기준)

# 파일 크기 조회 (크로스 플랫폼)
get_file_size() {
    stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null || wc -c < "$1"
}

echo "============================================"
echo " SNS Media Upload Test"
echo "============================================"

# ── 샘플 파일 확인 ──────────────────────────────
echo ""
echo "=== [준비] 샘플 파일 확인 ==="

if [ ! -f "$IMAGE_FILE" ]; then
    echo "  [ERROR] sample.png 없음 — $SCRIPT_DIR/media/ 에 직접 추가해주세요."
    exit 1
fi

if [ ! -f "$VIDEO_FILE" ]; then
    echo "  [ERROR] sample.mp4 없음 — $SCRIPT_DIR/media/ 에 직접 추가해주세요."
    exit 1
fi

IMAGE_SIZE=$(get_file_size "$IMAGE_FILE")
VIDEO_SIZE=$(get_file_size "$VIDEO_FILE")

echo "  sample.png: $IMAGE_SIZE bytes ($(( IMAGE_SIZE / 1024 / 1024 ))MB)"
echo "  sample.mp4: $VIDEO_SIZE bytes ($(( VIDEO_SIZE / 1024 / 1024 ))MB)"

rm -f "$COOKIES"

# ── [1] 로그인 ───────────────────────────────────
echo ""
echo "=== [1] 로그인 - $USER ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$USER&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# ════════════════════════════════════════════════
#  단일 업로드 — 이미지 (3MB ≤ 8MB)
# ════════════════════════════════════════════════

echo "============================================"
echo " [단일 업로드] 이미지 $(( IMAGE_SIZE / 1024 / 1024 ))MB"
echo "============================================"

# [2] Init 단일 업로드
echo ""
echo "=== [2] Init Single Upload (IMAGE, ${IMAGE_SIZE} bytes) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"mediaType\":\"IMAGE\",\"fileSize\":$IMAGE_SIZE}")
echo "$RESPONSE"

MEDIA_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
PRESIGNED_URL=$(echo "$RESPONSE" | grep -o '"presignedUrl":"http[^"]*"' | sed 's/"presignedUrl":"//;s/"$//')
echo -e "\n  Media ID: $MEDIA_ID"
echo "  Presigned URL: $PRESIGNED_URL"

# [3] 실제 파일 PUT → S3(RustFS)
echo ""
echo "=== [3] PUT sample.png → RustFS ==="
if [ -n "$PRESIGNED_URL" ]; then
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$PRESIGNED_URL" \
      -H "Content-Type: application/octet-stream" \
      --data-binary @"$IMAGE_FILE")
    echo "  HTTP Status: $HTTP_STATUS"
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "  파일 업로드 성공"
    else
        echo "  파일 업로드 실패 (status: $HTTP_STATUS)"
    fi
else
    echo "  [SKIP] presignedUrl 없음 — RustFS가 실행 중인지 확인하세요."
fi

# [4] 업로드 완료 처리
echo ""
echo "=== [4] POST /api/v1/media/uploaded (단일) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/media/uploaded" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"mediaId\":$MEDIA_ID}"
echo -e "\n"

# ════════════════════════════════════════════════
#  멀티파트 업로드 — 비디오 (12MB > 8MB → 2파트)
# ════════════════════════════════════════════════

VIDEO_PARTS=$(( (VIDEO_SIZE + PART_SIZE - 1) / PART_SIZE ))
echo "============================================"
echo " [멀티파트 업로드] 비디오 $(( VIDEO_SIZE / 1024 / 1024 ))MB → ${VIDEO_PARTS}파트"
echo "============================================"

# [5] Init 멀티파트 업로드
echo ""
echo "=== [5] Init Multipart Upload (VIDEO, ${VIDEO_SIZE} bytes, ${VIDEO_PARTS} parts) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"mediaType\":\"VIDEO\",\"fileSize\":$VIDEO_SIZE}")
echo "$RESPONSE"

MULTI_MEDIA_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\n  Multipart Media ID: $MULTI_MEDIA_ID"

# presignedUrlParts 배열에서 URL 추출 (http로 시작하는 것만)
PART_URLS=()
while IFS= read -r url; do
    [ -n "$url" ] && PART_URLS+=("$url")
done < <(echo "$RESPONSE" | grep -o '"presignedUrl":"http[^"]*"' | sed 's/"presignedUrl":"//;s/"$//')

echo "  파트 URL 수: ${#PART_URLS[@]}"
for i in "${!PART_URLS[@]}"; do
    echo "  Part $((i+1)): ${PART_URLS[$i]}"
done

# [6] 파일 분할 후 파트 업로드 → ETag 수집
echo ""
echo "=== [6] 파일 분할 및 파트 업로드 ==="

TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

split -b "$PART_SIZE" "$VIDEO_FILE" "$TEMP_DIR/part_"
PART_FILES=($(ls "$TEMP_DIR/part_"* | sort))
echo "  분할된 파트 수: ${#PART_FILES[@]}"

ETAGS=()
UPLOAD_SUCCESS=true

for i in "${!PART_FILES[@]}"; do
    PART_NUM=$((i+1))
    PART_FILE="${PART_FILES[$i]}"
    PART_URL="${PART_URLS[$i]}"
    PART_SIZE_ACTUAL=$(get_file_size "$PART_FILE")

    echo ""
    echo "  --- Part $PART_NUM ($(( PART_SIZE_ACTUAL / 1024 / 1024 ))MB) ---"

    if [ -z "$PART_URL" ]; then
        echo "  [SKIP] Part $PART_NUM URL 없음"
        UPLOAD_SUCCESS=false
        continue
    fi

    TEMP_HEADERS=$(mktemp)
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$PART_URL" \
      -H "Content-Type: application/octet-stream" \
      --data-binary @"$PART_FILE" \
      -D "$TEMP_HEADERS")

    ETAG=$(grep -i "^etag:" "$TEMP_HEADERS" | tr -d '\r' | sed 's/^[Ee][Tt][Aa][Gg]: *"*//;s/"*$//')
    rm -f "$TEMP_HEADERS"

    echo "  HTTP Status: $HTTP_STATUS"
    echo "  ETag: $ETAG"

    if [ "$HTTP_STATUS" = "200" ] && [ -n "$ETAG" ]; then
        ETAGS+=("$ETAG")
        echo "  Part $PART_NUM 업로드 성공"
    else
        echo "  Part $PART_NUM 업로드 실패"
        UPLOAD_SUCCESS=false
    fi
done

# [7] 멀티파트 완료 처리
echo ""
echo "=== [7] POST /api/v1/media/uploaded (멀티파트) ==="

# parts JSON 배열 구성
PARTS_JSON="["
for i in "${!ETAGS[@]}"; do
    PART_NUM=$((i+1))
    if [ $i -gt 0 ]; then
        PARTS_JSON+=","
    fi
    PARTS_JSON+="{\"partNumber\":$PART_NUM,\"eTag\":\"${ETAGS[$i]}\"}"
done
PARTS_JSON+="]"

echo "  Parts JSON: $PARTS_JSON"

if [ "$UPLOAD_SUCCESS" = true ] && [ ${#ETAGS[@]} -gt 0 ]; then
    curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/media/uploaded" \
      -H "Content-Type: application/json" \
      -b "$COOKIES" \
      -d "{\"mediaId\":$MULTI_MEDIA_ID,\"parts\":$PARTS_JSON}"
else
    echo "  [SKIP] 파트 업로드 실패 또는 ETag 없음 — RustFS 연결을 확인하세요."
    echo "  Mock ETag로 완료 요청을 전송합니다..."
    curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/media/uploaded" \
      -H "Content-Type: application/json" \
      -b "$COOKIES" \
      -d "{\"mediaId\":$MULTI_MEDIA_ID,\"parts\":[{\"partNumber\":1,\"eTag\":\"mock-etag-1\"},{\"partNumber\":2,\"eTag\":\"mock-etag-2\"}]}"
fi

echo -e "\n"

# ── Presigned URL 조회 ───────────────────────────
echo "============================================"
echo " [Presigned URL 조회] 업로드 완료된 미디어"
echo "============================================"

# [8] 이미지 미디어 presigned-url 조회
echo ""
echo "=== [8] GET /api/v1/media/$MEDIA_ID/presigned-url ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$BASE_URL/api/v1/media/$MEDIA_ID/presigned-url" \
  -b "$COOKIES"
echo -e "\n"

echo "============================================"
echo " 테스트 완료"
echo "============================================"
