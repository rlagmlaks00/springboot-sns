#!/bin/bash

BASE_URL="http://localhost:8080"

# 1. Signup - Create a new user (success)
echo "=== 1. Signup - Success ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "username": "testuser"
  }'
echo -e "\n"

# 2. Signup - Duplicate email (should fail)
echo "=== 2. Signup - Duplicate Email ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password456",
    "username": "anotheruser"
  }'
echo -e "\n"

# 3. Signup - Invalid email format (should fail)
echo "=== 3. Signup - Invalid Email Format ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "password": "password123",
    "username": "testuser2"
  }'
echo -e "\n"

# 4. Signup - Password too short (should fail)
echo "=== 4. Signup - Password Too Short ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test2@example.com",
    "password": "short",
    "username": "testuser2"
  }'
echo -e "\n"

# 5. Signup - Missing required fields (should fail)
echo "=== 5. Signup - Missing Email ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "password123",
    "username": "testuser3"
  }'
echo -e "\n"

# 6. Signup - Username too short (should fail)
echo "=== 6. Signup - Username Too Short ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test3@example.com",
    "password": "password123",
    "username": "a"
  }'
echo -e "\n"

# 7. Signup - Empty request body (should fail)
echo "=== 7. Signup - Empty Body ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{}'
echo -e "\n"
