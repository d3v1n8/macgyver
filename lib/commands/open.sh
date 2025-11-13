#!/bin/bash

# Open 명령어

bm_open() {
  local result
  result=$(find_bookmark "$1")

  if [ -z "$result" ]; then
    echo "❌ 북마크를 찾을 수 없습니다."
    exit 1
  fi

  local url
  url=$(echo "$result" | jq -r '.url')

  open "$url"
}
