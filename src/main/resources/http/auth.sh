#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"
REDIS_CONTAINER="springboot-sns-redis"

rm -f "$COOKIES"

# 1. Signup
echo "=== 1. Signup ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{"email": "auth1@example.com", "password": "password123", "username": "authuser1"}'
echo -e "\n"

# 2. Login
echo "=== 2. Login ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=auth1@example.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 3. Check Redis session
echo "=== 3. Check Redis Session ==="
docker exec "$REDIS_CONTAINER" redis-cli KEYS "spring:session:*"
echo -e "\n"

# 4. Access protected endpoint
echo "=== 4. Access /api/v1/me ==="
curl -s -X GET "$BASE_URL/api/v1/me" -b "$COOKIES"
echo -e "\n"

# 5. Logout
echo "=== 5. Logout ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X POST "$BASE_URL/api/v1/logout" -b "$COOKIES" -c "$COOKIES"
echo -e "\n"

# 6. Check Redis session after logout
echo "=== 6. Check Redis Session After Logout ==="
docker exec "$REDIS_CONTAINER" redis-cli KEYS "spring:session:*"
echo -e "\n"

# 7. Access protected endpoint after logout (should fail)
echo "=== 7. Access /api/v1/me After Logout (should return 302 or 401) ==="
curl -s -w "\nHTTP Status: %{http_code}\n" -X GET "$BASE_URL/api/v1/me" -b "$COOKIES"
echo -e "\n"
