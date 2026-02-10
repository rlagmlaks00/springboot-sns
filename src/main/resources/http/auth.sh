#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"
REDIS_CONTAINER="springboot-sns-redis"

rm -f "$COOKIES"

# 1. Login
echo "=== 1. Login ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=test1@example.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 2. Check Redis session
echo "=== 2. Check Redis Session ==="
docker exec "$REDIS_CONTAINER" redis-cli KEYS "spring:session:*"
echo -e "\n"

# 3. Access protected endpoint
echo "=== 3. Access /api/v1/me ==="
curl -s -X GET "$BASE_URL/api/v1/me" -b "$COOKIES"
echo -e "\n"

# 4. Logout
echo "=== 4. Logout ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/logout" -b "$COOKIES" -c "$COOKIES"
echo -e "\n"

# 5. Check Redis session after logout
echo "=== 5. Check Redis Session After Logout ==="
docker exec "$REDIS_CONTAINER" redis-cli KEYS "spring:session:*"
echo -e "\n"

# 6. Access protected endpoint after logout (should fail)
echo "=== 6. Access /api/v1/me After Logout (should return 302 or 401) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$BASE_URL/api/v1/me" -b "$COOKIES"
echo -e "\n"
