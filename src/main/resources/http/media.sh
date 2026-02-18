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

# 2. Init Single Upload (small file, <= 8MB)
echo "=== 2. Init Single Upload (1MB image) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"mediaType":"IMAGE","fileSize":1048576}')
echo "$RESPONSE"
MEDIA_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nMedia ID: $MEDIA_ID\n"

# 3. Mark Single Upload as Uploaded
echo "=== 3. Mark Single Upload as Uploaded ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/media/uploaded" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"mediaId\":$MEDIA_ID}"
echo -e "\n"

# 4. Init Multipart Upload (large file, > 8MB)
echo "=== 4. Init Multipart Upload (20MB video) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/media/init" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"mediaType":"VIDEO","fileSize":20971520}')
echo "$RESPONSE"
MULTI_MEDIA_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nMultipart Media ID: $MULTI_MEDIA_ID\n"

# 5. Mark Multipart Upload as Uploaded (with mock parts)
echo "=== 5. Mark Multipart Upload as Uploaded ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/media/uploaded" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"mediaId\":$MULTI_MEDIA_ID,\"parts\":[{\"partNumber\":1,\"eTag\":\"etag1\"},{\"partNumber\":2,\"eTag\":\"etag2\"},{\"partNumber\":3,\"eTag\":\"etag3\"}]}"
echo -e "\n"
