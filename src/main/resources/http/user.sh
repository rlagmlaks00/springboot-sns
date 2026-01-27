#!/bin/bash

BASE_URL="http://localhost:8080"

echo "=== Sign Up ==="
curl -X POST "$BASE_URL/api/users" \
  -H "Content-Type: application/json; charset=utf-8" \
  -d '{"email": "test@example.com", "password": "password123", "nickname": "tester"}'

echo -e "\n"

echo "=== Get User by ID ==="
curl -X GET "$BASE_URL/api/users/1"

echo -e "\n"

echo "=== Get User by Email ==="
curl -X GET "$BASE_URL/api/users/search?email=test@example.com"

echo -e "\n"
