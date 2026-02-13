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

# 2. Create Post
echo "=== 2. Create Post ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Post for view count test"}')
echo "$RESPONSE"
POST_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nPost ID: $POST_ID\n"

# 3. View Post (increment view count)
echo "=== 3. View Post (1st) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts/$POST_ID/view" \
  -b "$COOKIES"
echo -e "\n"

# 4. View Post again
echo "=== 4. View Post (2nd) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts/$POST_ID/view" \
  -b "$COOKIES"
echo -e "\n"

# 5. View Post again
echo "=== 5. View Post (3rd) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/posts/$POST_ID/view" \
  -b "$COOKIES"
echo -e "\n"

# 6. Get Post - check viewCount (before scheduler sync, should be 0 in DB)
echo "=== 6. Get Post - viewCount before sync ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES"
echo -e "\n"

# 7. Wait for scheduler (60s) and check again
echo "=== 7. Waiting 65s for scheduler sync... ==="
sleep 65

echo "=== 8. Get Post - viewCount after sync ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$POST_ID" \
  -b "$COOKIES"
echo -e "\n"
