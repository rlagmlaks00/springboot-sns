#!/bin/bash
export LANG=en_US.UTF-8

# ============================================
# Post-Media 통합 테스트 스크립트
# 실행 위치: src/main/resources/http/
#   cd src/main/resources/http && bash post-media.sh
#
# 사전 조건:
#   - Spring Boot 서버 실행 중 (localhost:8080)
#   - RustFS(S3 호환 스토리지) 실행 중
#   - ./media/sample.png 존재
#   - TestUser1, TestUser4 계정 생성 완료 (setup.sh 선행 실행)
# ============================================

BASE_URL="http://localhost:8080"
COOKIES="./cookies.txt"
COOKIES_OTHER="./cookies_other.txt"
IMAGE_FILE="./media/sample.png"
USER="TestUser4"
OTHER_USER="TestUser1"

# 파일 크기 조회 (크로스 플랫폼)
get_file_size() {
  stat -c%s "$1" 2>/dev/null || stat -f%z "$1" 2>/dev/null || wc -c < "$1"
}

echo "============================================"
echo " Post-Media 통합 테스트"
echo "============================================"

# ── 사전 확인 ──────────────────────────────────
echo ""
echo "=== [준비] 샘플 파일 확인 ==="
if [ ! -f "$IMAGE_FILE" ]; then
  echo "  [ERROR] sample.png 없음 — ./media/ 에 직접 추가해주세요."
  exit 1
fi
IMAGE_SIZE=$(get_file_size "$IMAGE_FILE")
echo "  sample.png: $IMAGE_SIZE bytes"

rm -f "$COOKIES" "$COOKIES_OTHER"

# ════════════════════════════════════════════════
#  정상 흐름: 미디어 업로드 → 게시글 생성
# ════════════════════════════════════════════════
echo ""
echo "============================================"
echo " [정상 흐름] 미디어 업로드 → 게시글 생성"
echo "============================================"

# [1] 로그인 — TestUser4
echo ""
echo "=== [1] 로그인 - $USER ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$USER&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# [2] 미디어 초기화 (IMAGE)
echo "=== [2] POST /api/v1/media/init — IMAGE 타입 초기화 ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  -d "{\"mediaType\":\"IMAGE\",\"fileSize\":$IMAGE_SIZE}")
echo "$RESPONSE"

MEDIA_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
PRESIGNED_URL=$(echo "$RESPONSE" | grep -o '"presignedUrl":"http[^"]*"' | sed 's/"presignedUrl":"//;s/"$//')
echo -e "\n  Media ID: $MEDIA_ID"
echo "  Presigned URL: $PRESIGNED_URL"
echo ""

# [3] sample.png → RustFS PUT
echo "=== [3] PUT presignedUrl — sample.png 업로드 ==="
if [ -n "$PRESIGNED_URL" ]; then
  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X PUT "$PRESIGNED_URL" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$IMAGE_FILE")
  echo "  HTTP Status: $HTTP_STATUS"
  if [ "$HTTP_STATUS" = "200" ]; then
    echo "  파일 업로드 성공"
  else
    echo "  [WARNING] 파일 업로드 실패 (RustFS가 실행 중인지 확인하세요)"
  fi
else
  echo "  [SKIP] presignedUrl 없음 — RustFS가 실행 중인지 확인하세요."
fi
echo ""

# [4] 업로드 완료 처리 (INIT → COMPLETED)
echo "=== [4] POST /api/v1/media/uploaded — 완료 처리 (INIT → COMPLETED) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/media/uploaded" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  -d "{\"mediaId\":$MEDIA_ID}"
echo -e "\n"

# [5] 미디어 포함 게시글 생성 → 201 기대
echo "=== [5] POST /api/v1/posts — mediaIds 포함 게시글 생성 (201 기대) ==="
DATA='{"content":"Post with media","mediaIds":['$MEDIA_ID']}'
RESPONSE=$(curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA")
echo "$RESPONSE"
POST_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\n  Created Post ID: $POST_ID\n"

# [6] 생성된 게시글 조회 — mediaIds 포함 확인
echo "=== [6] GET /api/v1/posts/$POST_ID — mediaIds 필드 확인 ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES" -c "$COOKIES"
echo -e "\n"

# [7] 미디어 없는 게시글 생성 → 201 기대 (기존 동작 유지)
echo "=== [7] POST /api/v1/posts — mediaIds 없이 게시글 생성 (201 기대) ==="
DATA='{"content":"Post without media"}'
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA"
echo -e "\n"

# ════════════════════════════════════════════════
#  예외 흐름: 검증 실패 케이스
# ════════════════════════════════════════════════
echo "============================================"
echo " [예외 흐름] 검증 실패 케이스"
echo "============================================"

# [8] 존재하지 않는 mediaId → 404 기대
echo ""
echo "=== [8] 존재하지 않는 mediaId(999999) → 404 기대 ==="
DATA='{"content":"Post with non-existent media","mediaIds":[999999]}'
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA"
echo -e "\n"

# [9] COMPLETED 아닌 미디어 (init만 수행, uploaded 미호출) → 400 기대
echo "=== [9] COMPLETED 아닌 미디어 (uploaded 미호출) → 400 기대 ==="

# init만 수행
echo "  --- 미디어 init 수행 (uploaded 호출 없음) ---"
INIT_ONLY_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  -d "{\"mediaType\":\"IMAGE\",\"fileSize\":$IMAGE_SIZE}")
echo "  $INIT_ONLY_RESPONSE"
INIT_ONLY_MEDIA_ID=$(echo "$INIT_ONLY_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo "  Init-only Media ID: $INIT_ONLY_MEDIA_ID"
echo ""

echo "  --- INIT 상태 미디어로 게시글 생성 시도 ---"
DATA='{"content":"Post with INIT status media","mediaIds":['$INIT_ONLY_MEDIA_ID']}'
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA"
echo -e "\n"

# [10] 타인 소유 미디어 첨부 시도 → 403 기대
echo "=== [10] 타인(TestUser1) 소유 미디어를 TestUser4 게시글에 첨부 → 403 기대 ==="

# TestUser1 로그인
echo "  --- TestUser1 로그인 ---"
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$OTHER_USER&password=password123" \
  -c "$COOKIES_OTHER" > /dev/null
echo "  로그인 완료"

# TestUser1의 미디어 init + uploaded
OTHER_RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES_OTHER" -c "$COOKIES_OTHER" \
  -d "{\"mediaType\":\"IMAGE\",\"fileSize\":$IMAGE_SIZE}")
OTHER_MEDIA_ID=$(echo "$OTHER_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
OTHER_PRESIGNED_URL=$(echo "$OTHER_RESPONSE" | grep -o '"presignedUrl":"http[^"]*"' | sed 's/"presignedUrl":"//;s/"$//')
echo "  TestUser1 Media ID: $OTHER_MEDIA_ID"

if [ -n "$OTHER_PRESIGNED_URL" ]; then
  curl -s -o /dev/null -X PUT "$OTHER_PRESIGNED_URL" \
    -H "Content-Type: application/octet-stream" \
    --data-binary @"$IMAGE_FILE"
fi

curl -s -o /dev/null -X POST "$BASE_URL/api/v1/media/uploaded" \
  -H "Content-Type: application/json" \
  -b "$COOKIES_OTHER" -c "$COOKIES_OTHER" \
  -d "{\"mediaId\":$OTHER_MEDIA_ID}"
echo "  TestUser1 미디어 COMPLETED 처리 완료"
echo ""

echo "  --- TestUser4 세션으로 TestUser1 미디어 첨부 시도 ---"
DATA='{"content":"Post with other users media","mediaIds":['$OTHER_MEDIA_ID']}'
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA"
echo -e "\n"

# [11] mediaIds 11개 초과 → 400 기대 (Bean Validation, MAX_MEDIA_COUNT=10)
echo "=== [11] mediaIds 11개 초과 → 400 기대 (MAX_MEDIA_COUNT=10) ==="
DATA='{"content":"Post with too many media","mediaIds":[1,2,3,4,5,6,7,8,9,10,11]}'
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA"
echo -e "\n"

# [12] 중복 mediaId → 400 기대
echo "=== [12] 중복 mediaId → 400 기대 ==="
DATA='{"content":"Post with duplicate media","mediaIds":['$MEDIA_ID','$MEDIA_ID']}'
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" -c "$COOKIES" \
  --data-binary "$DATA"
echo -e "\n"

echo "============================================"
echo " 테스트 완료"
echo "============================================"
