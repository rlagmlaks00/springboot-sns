#!/usr/bin/env bash

BASE_URL="http://localhost:8080"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

section() { echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${YELLOW}$1${NC}"; echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }
step()    { echo -e "\n${GREEN}▶ $1${NC}"; }
info()    { echo -e "  ${RED}ℹ $1${NC}"; }

# JSON 에서 숫자 id 추출
extract_id() {
  python -c "import sys,json; d=json.load(sys.stdin); print(d.get('id',''))" 2>/dev/null
}

# JSON pretty print
pp() { python -m json.tool 2>/dev/null || cat; }

# 타임라인 posts 배열 요약 출력
summarize_timeline() {
  python -c "
import sys, json
d = json.load(sys.stdin)
posts = d.get('posts', [])
cursor = d.get('nextCursor')
print(f'  총 {len(posts)}개 게시글, nextCursor={cursor}')
for p in posts:
    print(f'  [{p[\"type\"]:6}] id={p[\"id\"]:4} like={p[\"likeCount\"]} reply={p[\"replyCount\"]} repost={p[\"repostCount\"]} | {p[\"content\"][:60]}')
" 2>/dev/null
}

# ──────────────────────────────────────────────
# 공통 API 함수
# ──────────────────────────────────────────────

do_login() {   # do_login <username> <cookie_file>
  curl -s -X POST "$BASE_URL/api/v1/login" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=$1&password=password123" \
    -c "$2"
}

do_signup() {  # do_signup <email> <username>
  curl -s -X POST "$BASE_URL/api/v1/signup" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$1\",\"password\":\"password123\",\"username\":\"$2\"}" || true
}

do_post() {    # do_post <cookie_file> <content>  →  post JSON
  curl -s -X POST "$BASE_URL/api/v1/posts" \
    -H "Content-Type: application/json" \
    -b "$1" \
    -d "{\"content\":\"$2\"}"
}

do_reply() {   # do_reply <cookie_file> <content> <parentId>  →  reply JSON
  curl -s -X POST "$BASE_URL/api/v1/replies" \
    -H "Content-Type: application/json" \
    -b "$1" \
    -d "{\"content\":\"$2\",\"parentId\":$3}"
}

do_repost() {  # do_repost <cookie_file> <postId>  →  repost JSON
  curl -s -X POST "$BASE_URL/api/v1/reposts" \
    -H "Content-Type: application/json" \
    -b "$1" \
    -d "{\"repostId\":$2}"
}

do_quote() {   # do_quote <cookie_file> <content> <quoteId>  →  quote JSON
  curl -s -X POST "$BASE_URL/api/v1/quotes" \
    -H "Content-Type: application/json" \
    -b "$1" \
    -d "{\"content\":\"$2\",\"quoteId\":$3}"
}

do_follow()   { curl -s -X POST   "$BASE_URL/api/v1/follow/$2"   -b "$1" > /dev/null; }
do_unfollow() { curl -s -X DELETE "$BASE_URL/api/v1/follow/$2"   -b "$1" > /dev/null; }
do_like()     { curl -s -X POST   "$BASE_URL/api/v1/likes/$2"    -b "$1" > /dev/null; }
do_unlike()   { curl -s -X DELETE "$BASE_URL/api/v1/likes/$2"    -b "$1" > /dev/null; }
do_view()     { curl -s -X POST   "$BASE_URL/api/v1/posts/$2/view" -b "$1" > /dev/null; }

get_timeline()  { curl -s "$BASE_URL/api/v1/timeline${2:+?$2}"  -b "$1"; }
get_post()      { curl -s "$BASE_URL/api/v1/posts/$2"           -b "$1"; }
get_fcount()    { curl -s "$BASE_URL/api/v1/follow/count/$2"    -b "$1"; }

# ──────────────────────────────────────────────
section "[SETUP] 5명 계정 준비 및 로그인"
# ──────────────────────────────────────────────

rm -f c_u1.txt c_u2.txt c_u3.txt c_u4.txt c_u5.txt

# TestUser1~2 는 기존 계정, TestUser3~5 는 없으면 신규 생성
do_signup "test3@example.com" "TestUser3" > /dev/null
do_signup "test4@example.com" "TestUser4" > /dev/null
do_signup "test5@example.com" "TestUser5" > /dev/null

info "TestUser1 로그인"
do_login "TestUser1" "c_u1.txt" > /dev/null
info "TestUser2 로그인"
do_login "TestUser2" "c_u2.txt" > /dev/null
info "TestUser3 로그인"
do_login "TestUser3" "c_u3.txt" > /dev/null
info "TestUser4 로그인"
do_login "TestUser4" "c_u4.txt" > /dev/null
info "TestUser5 로그인"
do_login "TestUser5" "c_u5.txt" > /dev/null

step "세션 확인"
echo -n "  User1: "; curl -s "$BASE_URL/api/v1/me" -b "c_u1.txt"
echo ""
echo -n "  User2: "; curl -s "$BASE_URL/api/v1/me" -b "c_u2.txt"
echo ""

# ──────────────────────────────────────────────
section "[SCENARIO 1] TestUser1 에게 팔로워 4명 붙이기"
# 기대: User1 게시글이 User2~5 타임라인에 팬아웃됨
# ──────────────────────────────────────────────

info "User2~5 가 User1 팔로우"
do_follow "c_u2.txt" "TestUser1"; echo "  User2 → TestUser1 팔로우"
do_follow "c_u3.txt" "TestUser1"; echo "  User3 → TestUser1 팔로우"
do_follow "c_u4.txt" "TestUser1"; echo "  User4 → TestUser1 팔로우"
do_follow "c_u5.txt" "TestUser1"; echo "  User5 → TestUser1 팔로우"

step "TestUser1 팔로우 카운트 → followerCount=4 기대"
get_fcount "c_u1.txt" "TestUser1" | pp

step "TestUser1 게시글 3개 작성 → 4명 타임라인에 팬아웃"
RESP=$(do_post "c_u1.txt" "Hello from User1. Post #1"); echo "  $RESP" | pp
P1=$(echo "$RESP" | extract_id)

RESP=$(do_post "c_u1.txt" "User1 shares about the weather today. Post #2"); echo "  $RESP" | pp
P2=$(echo "$RESP" | extract_id)

RESP=$(do_post "c_u1.txt" "User1 recommends some music. Post #3"); echo "  $RESP" | pp
P3=$(echo "$RESP" | extract_id)

echo "  생성된 Post ID: P1=$P1, P2=$P2, P3=$P3"

step "TestUser2 타임라인 → User1 게시글 포함 기대"
get_timeline "c_u2.txt" | summarize_timeline

step "TestUser5 타임라인 → 동일하게 User1 게시글 포함 기대"
get_timeline "c_u5.txt" | summarize_timeline

# ──────────────────────────────────────────────
section "[SCENARIO 2] 복잡한 팔로우 관계 형성 (여러 명이 여러 명 팔로우)"
# 기대: User4 타임라인에 User1, User2, User3 게시글 모두 등장
# ──────────────────────────────────────────────

info "User2 → User3 팔로우 (User2는 이제 User1, User3 팔로우)"
do_follow "c_u2.txt" "TestUser3"; echo "  User2 → TestUser3 팔로우"

info "User3 → User2 팔로우 (맞팔)"
do_follow "c_u3.txt" "TestUser2"; echo "  User3 → TestUser2 팔로우"

info "User4 → User2, User3 추가 팔로우 (User4는 이제 User1, User2, User3 팔로우)"
do_follow "c_u4.txt" "TestUser2"; echo "  User4 → TestUser2 팔로우"
do_follow "c_u4.txt" "TestUser3"; echo "  User4 → TestUser3 팔로우"

info "User1 ↔ User2 맞팔"
do_follow "c_u1.txt" "TestUser2"; echo "  User1 → TestUser2 팔로우"

step "각 유저 팔로우 카운트 확인"
for u in TestUser1 TestUser2 TestUser3 TestUser4 TestUser5; do
  echo -n "  $u → "
  get_fcount "c_u1.txt" "$u"
  echo ""
done

# ──────────────────────────────────────────────
section "[SCENARIO 3] 여러 유저가 게시글 작성 → 각 팔로워 타임라인에 팬아웃"
# ──────────────────────────────────────────────

step "TestUser2 게시글 2개 작성 → User1, User3, User4 타임라인에 팬아웃"
RESP=$(do_post "c_u2.txt" "Hello from User2. Post #1")
P4=$(echo "$RESP" | extract_id); echo "  P4=$P4"

RESP=$(do_post "c_u2.txt" "User2 asks for lunch recommendations. Post #2")
P5=$(echo "$RESP" | extract_id); echo "  P5=$P5"

step "TestUser3 게시글 2개 작성 → User2, User4 타임라인에 팬아웃"
RESP=$(do_post "c_u3.txt" "Hello from User3. Post #1")
P6=$(echo "$RESP" | extract_id); echo "  P6=$P6"

RESP=$(do_post "c_u3.txt" "User3 asks about weekend plans. Post #2")
P7=$(echo "$RESP" | extract_id); echo "  P7=$P7"

step "TestUser1 타임라인 → User2 게시글 포함 기대 (맞팔)"
get_timeline "c_u1.txt" | summarize_timeline

step "TestUser4 타임라인 → User1, User2, User3 게시글 모두 포함 기대"
get_timeline "c_u4.txt" | summarize_timeline

# ──────────────────────────────────────────────
section "[SCENARIO 4] 여러 명이 같은 게시글에 답글(Reply)"
# 기대: 답글도 팬아웃됨 / replyCount 증가
# ──────────────────────────────────────────────

info "User2, User3, User4 가 User1 의 P1($P1) 에 각각 답글"

step "TestUser2 답글 작성 → User3, User4 타임라인에 팬아웃"
RESP=$(do_reply "c_u2.txt" "Great post from User2 reply!" "$P1")
echo "$RESP" | pp
R1=$(echo "$RESP" | extract_id)

step "TestUser3 답글 작성 → User2, User4 타임라인에 팬아웃"
RESP=$(do_reply "c_u3.txt" "Agreed, nice post - User3 reply!" "$P1")
echo "$RESP" | pp
R2=$(echo "$RESP" | extract_id)

step "TestUser4 답글 작성 → User1 타임라인에는 영향 없음 (User1은 User4 미팔로우)"
RESP=$(do_reply "c_u4.txt" "Hello everyone - User4 reply!" "$P1")
echo "$RESP" | pp

step "P1($P1) 답글 목록 → 3개, replyCount=3 기대"
curl -s "$BASE_URL/api/v1/posts/$P1/replies" -b "c_u1.txt" | \
  python -c "
import sys,json; d=json.load(sys.stdin)
posts=d.get('content',[])
print(f'  답글 수: {len(posts)}')
for p in posts: print(f'  [{p[\"type\"]}] id={p[\"id\"]} by={p[\"username\"]} | {p[\"content\"]}')
"

step "P1 게시글 replyCount 확인"
get_post "c_u1.txt" "$P1" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  replyCount={d[\"replyCount\"]}')
"

# ──────────────────────────────────────────────
section "[SCENARIO 5] 여러 명이 리포스트(Repost)"
# 기대: 리포스트도 팬아웃 / repostCount 증가
# ──────────────────────────────────────────────

step "TestUser2 가 P2($P2) 리포스트 → User1, User3, User4 타임라인에 팬아웃"
RESP=$(do_repost "c_u2.txt" "$P2")
echo "$RESP" | pp

step "TestUser3 가 P2($P2) 리포스트 → User2, User4 타임라인에 팬아웃"
RESP=$(do_repost "c_u3.txt" "$P2")
echo "$RESP" | pp

step "P2($P2) repostCount → 2 기대"
get_post "c_u1.txt" "$P2" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  repostCount={d[\"repostCount\"]}')
"

step "TestUser4 타임라인 → User2, User3 의 리포스트 포함 (type=REPOST)"
get_timeline "c_u4.txt" | summarize_timeline

step "TestUser2 리포스트 취소"
curl -s -X DELETE "$BASE_URL/api/v1/reposts/$P2" -b "c_u2.txt" | pp

step "P2 repostCount → 1 기대"
get_post "c_u1.txt" "$P2" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  repostCount={d[\"repostCount\"]}')
"

# ──────────────────────────────────────────────
section "[SCENARIO 6] 여러 명이 인용(Quote) + 인용의 인용"
# ──────────────────────────────────────────────

step "TestUser3 가 P3($P3) 인용 → User2, User4 타임라인에 팬아웃"
RESP=$(do_quote "c_u3.txt" "Sharing this great post by User3 quote!" "$P3")
echo "$RESP" | pp
Q1=$(echo "$RESP" | extract_id)

step "TestUser4 가 P3($P3) 인용 → User1, User2, User3 타임라인에 팬아웃 (안 됨, User4 팔로워 없음)"
RESP=$(do_quote "c_u4.txt" "Really good content - User4 quote!" "$P3")
echo "$RESP" | pp

step "TestUser2 가 User3 인용글(Q1=$Q1) 을 다시 인용 (인용의 인용)"
RESP=$(do_quote "c_u2.txt" "Quoting the quote by User2!" "$Q1")
echo "$RESP" | pp

step "P3 인용 목록 → 2개 기대 (User3, User4 인용)"
curl -s "$BASE_URL/api/v1/posts/$P3/quotes" -b "c_u1.txt" | \
  python -c "
import sys,json; d=json.load(sys.stdin)
posts=d.get('content',[])
print(f'  인용 수: {len(posts)}')
for p in posts: print(f'  [{p[\"type\"]}] id={p[\"id\"]} by={p[\"username\"]} | {p[\"content\"]}')
"

# ──────────────────────────────────────────────
section "[SCENARIO 7] 여러 명이 여러 게시글에 좋아요(Like)"
# 기대: likeCount 정확히 증감
# ──────────────────────────────────────────────

step "User2~5 가 P1($P1) 좋아요 → likeCount=4 기대"
do_like "c_u2.txt" "$P1"
do_like "c_u3.txt" "$P1"
do_like "c_u4.txt" "$P1"
do_like "c_u5.txt" "$P1"
get_post "c_u1.txt" "$P1" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  P1 likeCount={d[\"likeCount\"]} (기대: 4)')
"

step "User3~5 가 P2($P2) 좋아요 → likeCount=3 기대"
do_like "c_u3.txt" "$P2"
do_like "c_u4.txt" "$P2"
do_like "c_u5.txt" "$P2"
get_post "c_u1.txt" "$P2" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  P2 likeCount={d[\"likeCount\"]} (기대: 3)')
"

step "User4~5 가 P3($P3) 좋아요 → likeCount=2 기대"
do_like "c_u4.txt" "$P3"
do_like "c_u5.txt" "$P3"
get_post "c_u1.txt" "$P3" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  P3 likeCount={d[\"likeCount\"]} (기대: 2)')
"

step "User2 P1 좋아요 취소 → likeCount=3 기대"
do_unlike "c_u2.txt" "$P1"
get_post "c_u1.txt" "$P1" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  P1 likeCount={d[\"likeCount\"]} (기대: 3)')
"

# ──────────────────────────────────────────────
section "[SCENARIO 8] 조회수(View) 누적"
# 기대: viewCount 증가 (스케쥴러 배치로 반영, 즉시 반영 안 될 수 있음)
# ──────────────────────────────────────────────

step "User1~5 가 P1 조회 (5회) / User1~3 이 P2 조회 (3회)"
info "viewCount 는 1분 배치 반영이므로 즉시 0일 수 있음"
do_view "c_u1.txt" "$P1"; do_view "c_u2.txt" "$P1"
do_view "c_u3.txt" "$P1"; do_view "c_u4.txt" "$P1"; do_view "c_u5.txt" "$P1"
do_view "c_u1.txt" "$P2"; do_view "c_u2.txt" "$P2"; do_view "c_u3.txt" "$P2"

get_post "c_u1.txt" "$P1" | python -c "import sys,json; d=json.load(sys.stdin); print(f'  P1 viewCount={d[\"viewCount\"]}')"
get_post "c_u1.txt" "$P2" | python -c "import sys,json; d=json.load(sys.stdin); print(f'  P2 viewCount={d[\"viewCount\"]}')"

# ──────────────────────────────────────────────
section "[SCENARIO 9] 커서 기반 페이지네이션 (대량 게시글)"
# 기대: nextCursor 로 다음 페이지 조회 가능
# ──────────────────────────────────────────────

step "TestUser1 게시글 10개 추가 작성 → User2~5 타임라인에 팬아웃"
for i in $(seq 1 10); do
  do_post "c_u1.txt" "Pagination test post #$i by User1" > /dev/null
  sleep 0.05
done
echo "  10개 작성 완료"

step "TestUser4 타임라인 페이지1 (size=5)"
PAGE1=$(get_timeline "c_u4.txt" "size=5")
echo "$PAGE1" | summarize_timeline
C1=$(echo "$PAGE1" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('nextCursor','') or '')" 2>/dev/null)

step "TestUser4 타임라인 페이지2 (cursor=$C1, size=5)"
PAGE2=$(get_timeline "c_u4.txt" "cursor=$C1&size=5")
echo "$PAGE2" | summarize_timeline
C2=$(echo "$PAGE2" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('nextCursor','') or '')" 2>/dev/null)

step "TestUser4 타임라인 페이지3 (cursor=$C2, size=5)"
PAGE3=$(get_timeline "c_u4.txt" "cursor=$C2&size=5")
echo "$PAGE3" | summarize_timeline
C3=$(echo "$PAGE3" | python -c "import sys,json; d=json.load(sys.stdin); print(d.get('nextCursor','') or '')" 2>/dev/null)

step "TestUser4 타임라인 페이지4 (cursor=$C3, size=5)"
get_timeline "c_u4.txt" "cursor=$C3&size=5" | summarize_timeline

# ──────────────────────────────────────────────
section "[SCENARIO 10] 언팔로우 → 새 게시글 미노출 / 재팔로우 → 다시 팬아웃"
# ──────────────────────────────────────────────

step "User5 → User1 언팔로우"
do_unfollow "c_u5.txt" "TestUser1"; echo "  User5 → User1 언팔로우 완료"

step "User1 게시글 작성 (언팔 후) → User5 타임라인에 나타나면 안 됨"
RESP=$(do_post "c_u1.txt" "Post after User5 unfollowed - should NOT appear in User5 timeline")
PX=$(echo "$RESP" | extract_id); echo "  PX=$PX"

step "User5 타임라인 → PX($PX) 없어야 함 (기존 항목은 Redis 에 잔존)"
get_timeline "c_u5.txt" "size=5" | summarize_timeline

step "User5 → User1 재팔로우"
do_follow "c_u5.txt" "TestUser1"; echo "  User5 → User1 재팔로우 완료"

step "User1 게시글 작성 (재팔로우 후) → User5 타임라인에 나타나야 함"
RESP=$(do_post "c_u1.txt" "Post after User5 re-followed - SHOULD appear in User5 timeline")
PY=$(echo "$RESP" | extract_id); echo "  PY=$PY"

step "User5 타임라인 → PY($PY) 포함 기대"
get_timeline "c_u5.txt" "size=5" | summarize_timeline

# ──────────────────────────────────────────────
section "[SCENARIO 11] 게시글 수정 및 삭제"
# ──────────────────────────────────────────────

step "User2 가 P4($P4) 수정"
curl -s -X PATCH "$BASE_URL/api/v1/posts/$P4" \
  -H "Content-Type: application/json" \
  -b "c_u2.txt" \
  -d '{"content":"User2 edited this post content!"}' | pp

step "수정된 P4 단건 조회"
get_post "c_u1.txt" "$P4" | python -c "
import sys,json; d=json.load(sys.stdin)
print(f'  content={d[\"content\"]}')
print(f'  createdAt={d[\"createdAt\"]} / updatedAt={d[\"updatedAt\"]}')
"

step "User2 가 P5($P5) 삭제"
curl -s -X DELETE "$BASE_URL/api/v1/posts/$P5" -b "c_u2.txt" | pp

step "삭제된 P5 조회 → 오류 응답 기대"
get_post "c_u1.txt" "$P5" | pp

# ──────────────────────────────────────────────
section "[SUMMARY] 최종 팔로우 카운트"
# ──────────────────────────────────────────────

for u in TestUser1 TestUser2 TestUser3 TestUser4 TestUser5; do
  echo -n "  $u → "
  get_fcount "c_u1.txt" "$u"
  echo ""
done

section "[SUMMARY] 유저별 게시글 목록 (최근 5개)"
for cookie_user in "c_u1.txt:TestUser1" "c_u2.txt:TestUser2" "c_u3.txt:TestUser3"; do
  cookie="${cookie_user%%:*}"
  user="${cookie_user##*:}"
  step "$user 게시글"
  curl -s "$BASE_URL/api/v1/posts/user/$user?size=5" -b "$cookie" | \
    python -c "
import sys,json; d=json.load(sys.stdin)
posts=d.get('content',[])
for p in posts:
    print(f'  [{p[\"type\"]:6}] id={p[\"id\"]:4} like={p[\"likeCount\"]} reply={p[\"replyCount\"]} repost={p[\"repostCount\"]} | {p[\"content\"][:60]}')
"
done

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ 전체 시나리오 완료${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
