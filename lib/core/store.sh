#!/bin/bash

# 데이터 저장소 관리 함수들

# JSON 읽기
load_json() {
  cat "$MG_DB"
}

# JSON 저장
save_json() {
  printf '%s\n' "$1" > "$MG_DB"
  chmod 644 "$MG_DB"
}

# JSON 배열에서 name 또는 id로 북마크 찾기
find_bookmark() {
  load_json | jq -r --arg x "$1" '
    .bookmarks[] | select(.name == $x or .id == $x)
  '
}
