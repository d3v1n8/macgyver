#!/bin/bash

# 설정 파일 - 환경 변수 및 기본 설정

MG_DIR="$HOME/.mg"
MG_DB="$MG_DIR/bookmarks.json"

# 디렉토리 및 초기 DB 생성
mkdir -p "$MG_DIR"

if [ ! -f "$MG_DB" ]; then
  echo '{"bookmarks":[]}' > "$MG_DB"
fi

# ID 생성 함수
generate_id() {
  date +%s%N
}
