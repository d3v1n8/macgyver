#!/bin/bash

# Add 명령어

bm_add() {
  local name="$1"
  local url="$2"
  local group=""

  # 인자가 없으면 대화형으로 입력받기
  if [ -z "$name" ]; then
    echo -e "\033[1;37m북마크 추가\033[0m"
    echo -n -e "\033[37m링크명 → \033[0m"
    read -r name

    if [ -z "$name" ]; then
      echo "링크명은 필수입니다."
      return 1
    fi
  fi

  if [ -z "$url" ]; then
    echo -n -e "\033[37m링크 URL → \033[0m"
    read -r url

    if [ -z "$url" ]; then
      echo "URL은 필수입니다."
      return 1
    fi
  fi

  # 그룹 입력 (선택사항)
  if [ -z "$group" ]; then
    echo -n -e "\033[37m그룹 (선택) → \033[0m"
    read -r group
  fi

  # 옵션으로 제공된 경우 처리
  shift 2 2>/dev/null
  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --group*)
        group=$(echo "$1" | cut -d= -f2)
        ;;
    esac
    shift
  done

  local id
  id=$(generate_id)

  local updated
  updated=$(load_json | jq --arg id "$id" \
                           --arg name "$name" \
                           --arg url "$url" \
                           --arg group "$group" \
    '.bookmarks += [{
      id:$id,
      name:$name,
      url:$url,
      created_at:now,
      group:$group
    }]')

  save_json "$updated"

  echo ""
  echo -e "\033[1;37m추가 완료\033[0m $name"
  if [ -n "$group" ]; then
    echo -e "\033[90m그룹: $group\033[0m"
  fi
}
