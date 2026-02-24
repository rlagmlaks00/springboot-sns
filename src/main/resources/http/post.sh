#!/usr/bin/env bash
set -e

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

# 2. Create Post
echo "=== 2. Create Post ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Hello, this is my first post!"}')
echo "$RESPONSE"
POST_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nCreated Post ID: $POST_ID\n"

# 3. Get Post by ID (check type field)
echo "=== 3. Get Post by ID ($POST_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES"
echo -e "\n"

# 4. Update Post
echo "=== 4. Update Post ($POST_ID) ==="
curl -s -X PATCH "$BASE_URL/api/v1/posts/$POST_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Updated post content!"}'
echo -e "\n"

# 5. Get Post after Update
echo "=== 5. Get Post after Update ($POST_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6. Get Posts by User (with pageable)
echo "=== 6. Get Posts by User ($USER) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/user/$USER?page=0&size=10" \
  -b "$COOKIES"
echo -e "\n"

# 7. Get Posts by User - max page size test (size=999 should be capped to 100)
echo "=== 7. Get Posts by User - max page size test ==="
curl -s -X GET "$BASE_URL/api/v1/posts/user/$USER?page=0&size=999" \
  -b "$COOKIES"
echo -e "\n"

# 8. Get non-existent post (should return 404)
echo "=== 8. Get non-existent post (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$BASE_URL/api/v1/posts/999999" \
  -b "$COOKIES"
echo -e "\n"

# 9. Delete Post
echo "=== 9. Delete Post ($POST_ID) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES"
echo -e "\n"

# 10. Get Post after Delete (should return 404)
echo "=== 10. Get Post after Delete (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES"
echo -e "\n"
