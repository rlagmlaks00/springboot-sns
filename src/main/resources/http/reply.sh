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

# 2. Create Post (reply target)
echo "=== 2. Create Post (reply target) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Post for reply test"}')
echo "$RESPONSE"
PARENT_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nParent Post ID: $PARENT_ID\n"

# 3. Create Reply
echo "=== 3. Create Reply ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/replies" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"content\":\"This is a reply!\",\"parentId\":$PARENT_ID}")
echo "$RESPONSE"
REPLY_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nReply ID: $REPLY_ID\n"

# 4. Create another Reply
echo "=== 4. Create another Reply ==="
curl -s -X POST "$BASE_URL/api/v1/replies" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"content\":\"This is another reply!\",\"parentId\":$PARENT_ID}"
echo -e "\n"

# 5. Get Reply by ID (check type=REPLY)
echo "=== 5. Get Reply by ID ($REPLY_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$REPLY_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6. Get Parent Post - check replyCount
echo "=== 6. Get Parent Post - check replyCount ($PARENT_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$PARENT_ID" \
  -b "$COOKIES"
echo -e "\n"

# 7. Get Replies for Post
echo "=== 7. Get Replies for Post ($PARENT_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$PARENT_ID/replies?page=0&size=10" \
  -b "$COOKIES"
echo -e "\n"

# 8. Delete Reply
echo "=== 8. Delete Reply ($REPLY_ID) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/replies/$REPLY_ID" \
  -b "$COOKIES"
echo -e "\n"

# 9. Get Parent Post - check replyCount decreased
echo "=== 9. Get Parent Post - check replyCount decreased ($PARENT_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$PARENT_ID" \
  -b "$COOKIES"
echo -e "\n"

# 10. Delete non-existent reply (should return 404)
echo "=== 10. Delete non-existent reply (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/replies/999999" \
  -b "$COOKIES"
echo -e "\n"

# 11. Reply to non-existent post (should return 404)
echo "=== 11. Reply to non-existent post (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/replies" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Reply to nothing","parentId":999999}'
echo -e "\n"

# 12. Reply with negative parentId (should return 400 validation error)
echo "=== 12. Reply with negative parentId (should return 400) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/replies" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Reply with negative id","parentId":-1}'
echo -e "\n"
