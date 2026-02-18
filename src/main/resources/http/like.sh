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

# 2. Create Post (like target)
echo "=== 2. Create Post (like target) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Post for like test"}')
echo "$RESPONSE"
TARGET_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nTarget Post ID: $TARGET_ID\n"

# 3. Check like status before liking (should return false)
echo "=== 3. Check like status (should be false) ==="
curl -s -X GET "$BASE_URL/api/v1/likes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 4. Like Post
echo "=== 4. Like Post ==="
curl -s -X POST "$BASE_URL/api/v1/likes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 5. Check like status after liking (should return true)
echo "=== 5. Check like status (should be true) ==="
curl -s -X GET "$BASE_URL/api/v1/likes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6. Get Post - check likeCount increased
echo "=== 6. Get Post - check likeCount ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 7. Duplicate Like (should return 409)
echo "=== 7. Duplicate Like (should return 409) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/likes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 8. Unlike Post
echo "=== 8. Unlike Post ($TARGET_ID) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/likes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 9. Get Post after Unlike - check likeCount decreased
echo "=== 9. Get Post after Unlike ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 10. Unlike non-liked post (should return 404)
echo "=== 10. Unlike non-liked post (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/likes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 11. Like non-existent post (should return 404)
echo "=== 11. Like non-existent post (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/likes/999999" \
  -b "$COOKIES"
echo -e "\n"
