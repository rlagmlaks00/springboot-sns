#!/bin/bash

set -euo pipefail
set -x  # 실행 명령 추적

BASE_URL="http://localhost:8080"
COOKIES="./cookies.txt"
COOKIES_OTHER="./cookies_other.txt"
IMAGE_FILE="./media/sample.png"
USER="TestUser4"
OTHER_USER="TestUser1"

get_file_size() {
  stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null || wc -c < "$1"
}

print_response() {
  BODY="$1"
  STATUS="$2"
  echo "----------------------------------------"
  echo "HTTP STATUS: $STATUS"
  echo "BODY:"
  echo "$BODY"
  echo "----------------------------------------"
}

echo "===== DEBUG MODE ENABLED ====="

rm -f "$COOKIES" "$COOKIES_OTHER"

# ──────────────────────────────────────────────
# [1] 로그인
# ──────────────────────────────────────────────
echo "=== LOGIN: $USER ==="

LOGIN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$USER&password=password123" \
  -c "$COOKIES")

LOGIN_BODY=$(echo "$LOGIN_RESPONSE" | sed '$d')
LOGIN_STATUS=$(echo "$LOGIN_RESPONSE" | tail -n1)
print_response "$LOGIN_BODY" "$LOGIN_STATUS"

echo "Cookies after login:"
cat "$COOKIES" || true

# ──────────────────────────────────────────────
# [2] media/init
# ──────────────────────────────────────────────
IMAGE_SIZE=$(get_file_size "$IMAGE_FILE")

INIT_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  -d "{\"mediaType\":\"IMAGE\",\"fileSize\":$IMAGE_SIZE}")

INIT_BODY=$(echo "$INIT_RESPONSE" | sed '$d')
INIT_STATUS=$(echo "$INIT_RESPONSE" | tail -n1)
print_response "$INIT_BODY" "$INIT_STATUS"

MEDIA_ID=$(echo "$INIT_BODY" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*' || true)
PRESIGNED_URL=$(echo "$INIT_BODY" | grep -o '"presignedUrl":"http[^"]*"' | sed 's/"presignedUrl":"//;s/"$//' || true)

if [ -z "${MEDIA_ID:-}" ]; then
  echo "[FATAL] MEDIA_ID 추출 실패"
  exit 1
fi

# ──────────────────────────────────────────────
# [3] S3 업로드
# ──────────────────────────────────────────────
if [ -n "${PRESIGNED_URL:-}" ]; then
  curl -v -X PUT "$PRESIGNED_URL" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$IMAGE_FILE"
fi

# ──────────────────────────────────────────────
# [4] media/uploaded
# ──────────────────────────────────────────────
UPLOADED_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v1/media/uploaded" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  -d "{\"mediaId\":$MEDIA_ID}")

UPLOADED_BODY=$(echo "$UPLOADED_RESPONSE" | sed '$d')
UPLOADED_STATUS=$(echo "$UPLOADED_RESPONSE" | tail -n1)
print_response "$UPLOADED_BODY" "$UPLOADED_STATUS"

# ──────────────────────────────────────────────
# [5] 게시글 생성
# ──────────────────────────────────────────────
POST_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json; charset=UTF-8" \
  -b "$COOKIES" -c "$COOKIES" \
  -d "{\"content\":\"DEBUG contents\",\"mediaIds\":[$MEDIA_ID]}")

POST_BODY=$(echo "$POST_RESPONSE" | sed '$d')
POST_STATUS=$(echo "$POST_RESPONSE" | tail -n1)
print_response "$POST_BODY" "$POST_STATUS"

POST_ID=$(echo "$POST_BODY" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*' || true)

if [ -z "${POST_ID:-}" ]; then
  echo "[WARNING] POST_ID 추출 실패"
fi

# ──────────────────────────────────────────────
# [6] 게시글 조회
# ──────────────────────────────────────────────
if [ -n "${POST_ID:-}" ]; then
  GET_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
    -b "$COOKIES" -c "$COOKIES")

  GET_BODY=$(echo "$GET_RESPONSE" | sed '$d')
  GET_STATUS=$(echo "$GET_RESPONSE" | tail -n1)
  print_response "$GET_BODY" "$GET_STATUS"
fi

echo "===== DEBUG SCRIPT COMPLETED ====="
