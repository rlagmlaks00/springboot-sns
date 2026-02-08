#!/bin/bash

BASE_URL="http://localhost:8080"
COOKIES="cookies.txt"

rm -f "$COOKIES"

# 1. 회원가입 - 사용자 A
echo "=== 1. 회원가입 - 사용자 A ==="
RESPONSE_A=$(curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "userA@test.com",
    "password": "password123",
    "username": "UserA"
  }')
echo "$RESPONSE_A"
USER_A_ID=$(echo "$RESPONSE_A" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
echo "(userA_id=$USER_A_ID)"
echo -e "\n"

# 2. 회원가입 - 사용자 B
echo "=== 2. 회원가입 - 사용자 B ==="
RESPONSE_B=$(curl -s -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "userB@test.com",
    "password": "password123",
    "username": "UserB"
  }')
echo "$RESPONSE_B"
USER_B_ID=$(echo "$RESPONSE_B" | grep -o '"id":[0-9]*' | grep -o '[0-9]*')
echo "(userB_id=$USER_B_ID)"
echo -e "\n"

# 3. 로그인 - 사용자 A
echo "=== 3. 로그인 - 사용자 A ==="
curl -s -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "email=userA@test.com&password=password123" \
  -c "$COOKIES"
echo -e "\n"

# 4. 팔로우 - A가 B를 팔로우
echo "=== 4. 팔로우 - A가 B를 팔로우 ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 4-1. 팔로우 수 조회 - 사용자 A (following: 1)
echo "=== 4-1. 팔로우 수 조회 - 사용자 A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_A_ID" \
  -b "$COOKIES"
echo -e "\n"

# 4-2. 팔로우 수 조회 - 사용자 B (follower: 1)
echo "=== 4-2. 팔로우 수 조회 - 사용자 B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_B_ID" \
  -b "$COOKIES"
echo -e "\n"

# 5. 팔로우 중복 - A가 B를 다시 팔로우 (실패)
echo "=== 5. 팔로우 중복 (실패) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 6. 자기 자신 팔로우 (실패)
echo "=== 6. 자기 자신 팔로우 (실패) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/$USER_A_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 7. 언팔로우 - A가 B를 언팔로우
echo "=== 7. 언팔로우 - A가 B를 언팔로우 ==="
curl -s -X DELETE "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 7-1. 언팔로우 후 팔로우 수 조회 - 사용자 A (following: 0)
echo "=== 7-1. 언팔로우 후 팔로우 수 조회 - 사용자 A ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_A_ID" \
  -b "$COOKIES"
echo -e "\n"

# 7-2. 언팔로우 후 팔로우 수 조회 - 사용자 B (follower: 0)
echo "=== 7-2. 언팔로우 후 팔로우 수 조회 - 사용자 B ==="
curl -s -X GET "$BASE_URL/api/v1/follow/count/$USER_B_ID" \
  -b "$COOKIES"
echo -e "\n"

# 8. 언팔로우 중복 - A가 B를 다시 언팔로우 (실패)
echo "=== 8. 언팔로우 중복 (실패) ==="
curl -s -X DELETE "$BASE_URL/api/v1/follow/$USER_B_ID" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"

# 9. 존재하지 않는 사용자 팔로우 (실패)
echo "=== 9. 존재하지 않는 사용자 팔로우 (실패) ==="
curl -s -X POST "$BASE_URL/api/v1/follow/9999" \
  -H "Content-Type: application/json" \
  -b "$COOKIES"
echo -e "\n"
