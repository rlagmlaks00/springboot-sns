#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"

rm -f "$COOKIES"

# 1. Login - TestUser1 (A)
echo "=== 1. Login - TestUser1 (A) ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=test1@example.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 1-1. Get User A ID
echo "=== 1-1. Get User A ID ==="
RESPONSE_A=$(curl -s -X GET "$BASE_URL/api/v1/me" -b "$COOKIES")
echo "$RESPONSE_A"
USER_A_ID=$(echo "$RESPONSE_A" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
echo "(userA_id=$USER_A_ID)"
echo -e "\n"

# 1-2. Login - TestUser2 (B) to get ID
echo "=== 1-2. Login - TestUser2 (B) ==="
rm -f "$COOKIES"
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=test2@example.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 1-3. Get User B ID
echo "=== 1-3. Get User B ID ==="
RESPONSE_B=$(curl -s -X GET "$BASE_URL/api/v1/me" -b "$COOKIES")
echo "$RESPONSE_B"
USER_B_ID=$(echo "$RESPONSE_B" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
echo "(userB_id=$USER_B_ID)"
echo -e "\n"

# 2. Re-login as User A for follow tests
echo "=== 2. Re-login as User A ==="
rm -f "$COOKIES"
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=test1@example.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 3. Follow - A follows B
echo "=== 3. Follow - A follows B ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 3-1. Follow count - User A (following: 1)
echo "=== 3-1. Follow count - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_A_ID" \
  -b "$COOKIES"
echo -e "\n"

# 3-2. Follow count - User B (follower: 1)
echo "=== 3-2. Follow count - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_B_ID" \
  -b "$COOKIES"
echo -e "\n"

# 3-3. Follower list - User B (A is follower)
echo "=== 3-3. Follower list - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followers/$USER_B_ID?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 3-4. Following list - User A (following B)
echo "=== 3-4. Following list - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followings/$USER_A_ID?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 4. Duplicate follow - A follows B again (should fail)
echo "=== 4. Duplicate follow (should fail) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 5. Self follow (should fail)
echo "=== 5. Self follow (should fail) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_A_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 6. Unfollow - A unfollows B
echo "=== 6. Unfollow - A unfollows B ==="
curl -s -X DELETE "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 6-1. Follow count after unfollow - User A (following: 0)
echo "=== 6-1. Follow count after unfollow - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_A_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6-2. Follow count after unfollow - User B (follower: 0)
echo "=== 6-2. Follow count after unfollow - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_B_ID" \
  -b "$COOKIES"
echo -e "\n"

# 6-3. Follower list after unfollow - User B (empty)
echo "=== 6-3. Follower list after unfollow - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followers/$USER_B_ID?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 6-4. Following list after unfollow - User A (empty)
echo "=== 6-4. Following list after unfollow - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followings/$USER_A_ID?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 7. Duplicate unfollow - A unfollows B again (should fail)
echo "=== 7. Duplicate unfollow (should fail) ==="
curl -s -X DELETE "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 8. Follow non-existent user (should fail)
echo "=== 8. Follow non-existent user (should fail) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/9999" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"
