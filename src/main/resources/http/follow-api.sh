#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"
USER_A="TestUser1"
USER_B="TestUser2"

rm -f "$COOKIES"

# 1. Login - TestUser1 (A)
echo "=== 1. Login - $USER_A (A) ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=$USER_A&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 2. Follow - A follows B
echo "=== 2. Follow - A follows B ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_B" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 2-1. My follow count - User A (following: 1)
echo "=== 2-1. My follow count - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/me" \
  -b "$COOKIES"
echo -e "\n"

# 2-2. Follow count - User B (follower: 1)
echo "=== 2-2. Follow count - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_B" \
  -b "$COOKIES"
echo -e "\n"

# 2-3. Follower list - User B (A is follower)
echo "=== 2-3. Follower list - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followers/$USER_B?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 2-4. Following list - User A (following B)
echo "=== 2-4. Following list - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followings/$USER_A?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 3. Duplicate follow - A follows B again (should fail)
echo "=== 3. Duplicate follow (should fail) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_B" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 4. Self follow (should fail)
echo "=== 4. Self follow (should fail) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_A" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 5. Unfollow - A unfollows B
echo "=== 5. Unfollow - A unfollows B ==="
curl -s -X DELETE "$BASE_URL/api/v1/follow/$USER_B" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 5-1. My follow count after unfollow - User A (following: 0)
echo "=== 5-1. My follow count after unfollow - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/me" \
  -b "$COOKIES"
echo -e "\n"

# 5-2. Follow count after unfollow - User B (follower: 0)
echo "=== 5-2. Follow count after unfollow - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_B" \
  -b "$COOKIES"
echo -e "\n"

# 5-3. Follower list after unfollow - User B (empty)
echo "=== 5-3. Follower list after unfollow - User B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followers/$USER_B?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 5-4. Following list after unfollow - User A (empty)
echo "=== 5-4. Following list after unfollow - User A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/followings/$USER_A?page=0&size=20" \
  -b "$COOKIES"
echo -e "\n"

# 6. Duplicate unfollow - A unfollows B again (should fail)
echo "=== 6. Duplicate unfollow (should fail) ==="
curl -s -X DELETE "$BASE_URL/api/v1/follow/$USER_B" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 7. Follow non-existent user (should fail)
echo "=== 7. Follow non-existent user (should fail) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/NonExistentUser" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"
