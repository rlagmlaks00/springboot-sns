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

# 2. Create Post (quote target)
echo "=== 2. Create Post (quote target) ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/posts" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Post for quote test"}')
echo "$RESPONSE"
TARGET_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nTarget Post ID: $TARGET_ID\n"

# 3. Create Quote (check originalPost in response)
echo "=== 3. Create Quote ==="
RESPONSE=$(curl -s -X POST "$BASE_URL/api/v1/quotes" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"content\":\"This is a quote with my thoughts!\",\"quoteId\":$TARGET_ID}")
echo "$RESPONSE"
QUOTE_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
echo -e "\nQuote ID: $QUOTE_ID\n"

# 4. Get Quote by ID (check type=QUOTE and originalPost)
echo "=== 4. Get Quote by ID ($QUOTE_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$QUOTE_ID" \
  -b "$COOKIES"
echo -e "\n"

# 5. Get Original Post - check repostCount
echo "=== 5. Get Original Post - check repostCount ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6. Duplicate Quote (should return 409)
echo "=== 6. Duplicate Quote (should return 409) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/quotes" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d "{\"content\":\"Another quote attempt\",\"quoteId\":$TARGET_ID}"
echo -e "\n"

# 7. Get Quotes for Post
echo "=== 7. Get Quotes for Post ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID/quotes?page=0&size=10" \
  -b "$COOKIES"
echo -e "\n"

# 8. Delete Quote
echo "=== 8. Delete Quote ($TARGET_ID) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X DELETE "$BASE_URL/api/v1/quotes/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 9. Get Original Post after Quote Delete - check repostCount decreased
echo "=== 9. Get Original Post after Quote Delete ($TARGET_ID) ==="
curl -s -X GET "$BASE_URL/api/v1/posts/$TARGET_ID" \
  -b "$COOKIES"
echo -e "\n"

# 10. Quote non-existent post (should return 404)
echo "=== 10. Quote non-existent post (should return 404) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/quotes" \
  -H "Content-Type: application/json" \
  -b "$COOKIES" \
  -d '{"content":"Quote nothing","quoteId":999999}'
echo -e "\n"
