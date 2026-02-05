#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"

# Clean up previous cookies
rm -f "$COOKIES"

# Setup: Create a test user first
echo "=== Setup: Create Test User ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "auth@example.com",
    "password": "password123",
    "username": "authuser"
  }'
echo -e "\n"

# 1. Login - Success
echo "=== 1. Login - Success ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=auth@example.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 2. Access protected endpoint - With session (should succeed)
echo "=== 2. Access Protected Endpoint - With Session ==="
curl -s -X GET "$BASE_URL/api/v1/me" \
  -b "$COOKIES"
echo -e "\n"

# 3. Logout - Success
echo "=== 3. Logout - Success ==="
curl -s -X POST "$BASE_URL/api/v1/logout" \
  -b "$COOKIES" \
  -c "$COOKIES"
echo -e "\n"

# 4. Access protected endpoint - After logout (should fail)
echo "=== 4. Access Protected Endpoint - After Logout ==="
curl -s -X GET "$BASE_URL/api/v1/me" \
  -b "$COOKIES"
echo -e "\n"

# 5. Login - Wrong password (should fail)
echo "=== 5. Login - Wrong Password ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=auth@example.com&password=wrongpassword"
echo -e "\n"

# 6. Login - Non-existent email (should fail)
echo "=== 6. Login - Non-existent Email ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=notexist@example.com&password=password123"
echo -e "\n"

# 7. Login - Empty credentials (should fail)
echo "=== 7. Login - Empty Credentials ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d ""
echo -e "\n"

# 8. Access protected endpoint - Without session (should fail)
echo "=== 8. Access Protected Endpoint - Without Session ==="
rm -f "$COOKIES"
curl -s -X GET "$BASE_URL/api/v1/me"
echo -e "\n"

# Clean up
rm -f "$COOKIES"
