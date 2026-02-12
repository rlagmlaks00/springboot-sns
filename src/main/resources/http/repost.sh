#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"
USER="TestUser1"

rm -f "$COOKIES"

# 1. Login
echo "=== 1. Login - $USER ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$USER&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 2. Create Post (repost target)
echo "=== 2. Create Post (repost target) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Post for repost test"}')
echo "$RESPONSE"
TARGET_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nTarget Post ID: $TARGET_ID\n"

# 3. Create Repost (check originalPost in response)
echo "=== 3. Create Repost ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/reposts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"repostId\":$TARGET_ID}")
echo "$RESPONSE"
REPOST_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nRepost ID: $REPOST_ID\n"

# 4. Get Repost by ID (check type=REPOST and originalPost)
echo "=== 4. Get Repost by ID ($REPOST_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$REPOST_ID" \
  -b "$COOKIES"
echo -e "\n"

# 5. Get Original Post - check repostCount
echo "=== 5. Get Original Post - check repostCount ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6. Duplicate Repost (should return 409)
echo "=== 6. Duplicate Repost (should return 409) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/reposts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"repostId\":$TARGET_ID}"
echo -e "\n"

# 7. Delete Repost
echo "=== 7. Delete Repost ($TARGET_ID) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/reposts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 8. Get Original Post after Repost Delete - check repostCount decreased
echo "=== 8. Get Original Post after Repost Delete ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 9. Repost non-existent post (should return 404)
echo "=== 9. Repost non-existent post (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/reposts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"repostId":999999}'
echo -e "\n"
