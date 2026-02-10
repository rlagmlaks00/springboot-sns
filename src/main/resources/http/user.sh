#!/bin/bash

BASE_URL="http://localhost:8080"

# 1. Signup - Duplicate email (should fail, test1@example.com already exists)
echo "=== 1. Signup - Duplicate Email ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test1@example.com",
    "password": "password456",
    "username": "anotheruser"
  }'
echo -e "\n"

# 2. Signup - Invalid email format (should fail)
echo "=== 2. Signup - Invalid Email Format ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "invalid-email",
    "password": "password123",
    "username": "testuser2"
  }'
echo -e "\n"

# 3. Signup - Password too short (should fail)
echo "=== 3. Signup - Password Too Short ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "new@example.com",
    "password": "short",
    "username": "testuser2"
  }'
echo -e "\n"

# 4. Signup - Missing required fields (should fail)
echo "=== 4. Signup - Missing Email ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "password": "password123",
    "username": "testuser3"
  }'
echo -e "\n"

# 5. Signup - Username too short (should fail)
echo "=== 5. Signup - Username Too Short ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "new2@example.com",
    "password": "password123",
    "username": "a"
  }'
echo -e "\n"

# 6. Signup - Empty request body (should fail)
echo "=== 6. Signup - Empty Body ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{}'
echo -e "\n"
