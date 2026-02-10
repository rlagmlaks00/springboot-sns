#!/bin/bash

# ============================================
# One-time setup script for test accounts
# Run this script only once after DB initialization
# ============================================

BASE_URL="http://localhost:8080"

echo "============================================"
echo "  Setting up test accounts (one-time only)"
echo "============================================"
echo ""

# 1. Test Account 1
echo "=== 1. Create TestUser1 ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test1@example.com",
    "password": "password123",
    "username": "TestUser1"
  }'
echo -e "\n"

# 2. Test Account 2
echo "=== 2. Create TestUser2 ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test2@example.com",
    "password": "password123",
    "username": "TestUser2"
  }'
echo -e "\n"

# 3. Test Account 3
echo "=== 3. Create TestUser3 ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test3@example.com",
    "password": "password123",
    "username": "TestUser3"
  }'
echo -e "\n"

# 4. Test Account 4
echo "=== 4. Create TestUser4 ==="
curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test4@example.com",
    "password": "password123",
    "username": "TestUser4"
  }'
echo -e "\n"

echo "============================================"
echo "  Setup complete!"
echo "  Accounts: test1~test4@example.com"
echo "  Password: password123"
echo "============================================"
