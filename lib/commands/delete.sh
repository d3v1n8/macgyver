#!/bin/bash

# Delete 명령어 (대화형)

bm_delete() {
  local target="$1"
  local force="$2"

  # 인자가 있으면 바로 삭제 (기존 방식)
  if [ -n "$target" ]; then
    if [ "$force" != "--force" ]; then
      echo "정말 삭제하시겠습니까? (y/n)"
      read -r yn
      [[ "$yn" != "y" ]] && return 0
    fi

    local updated
    updated=$(load_json | jq --arg x "$target" '
      .bookmarks |= map(select(.name != $x and .id != $x))
    ')

    save_json "$updated"
    echo "🗑 삭제 완료: $target"
    return 0
  fi

  # 인자가 없으면 대화형 모드
  clear
  echo -e "\033[1;37m"
  echo -e "    ___  ___"
  echo -e "   |   \\/   |"
  echo -e "   | |\\  /| | __ _  ___"
  echo -e "   | | \\/ | |/ _\`|/ __|"
  echo -e "   | |    | | (_| | (__"
  echo -e "   |_|    |_|\\__, |\\___|"
  echo -e "              __/ |"
  echo -e "             |___/"
  echo -e "\033[0m\033[1;37m   🔧 북마크 삭제 🔧\033[0m"
  echo ""
  echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  # 모든 북마크 가져오기
  local bookmarks_json=$(load_json | jq -r '.bookmarks[] | .name')
  local bookmarks=()
  local groups=()
  local urls=()

  while IFS= read -r bm; do
    if [ -n "$bm" ]; then
      bookmarks+=("$bm")
    fi
  done <<< "$bookmarks_json"

  # 각 북마크의 그룹과 URL 정보 가져오기
  for bm in "${bookmarks[@]}"; do
    local group=$(load_json | jq -r --arg name "$bm" '.bookmarks[] | select(.name == $name) | .group // "없음"')
    local url=$(load_json | jq -r --arg name "$bm" '.bookmarks[] | select(.name == $name) | .url')
    groups+=("$group")
    urls+=("$url")
  done

  if [ ${#bookmarks[@]} -eq 0 ]; then
    echo "📭 삭제할 북마크가 없습니다."
    return 0
  fi

  local selected=0
  local total=${#bookmarks[@]}

  draw_delete_screen() {
    clear
    echo -e "\033[1;37m"
    echo -e "    ___  ___"
    echo -e "   |   \\/   |"
    echo -e "   | |\\  /| | __ _  ___"
    echo -e "   | | \\/ | |/ _\`|/ __|"
    echo -e "   | |    | | (_| | (__"
    echo -e "   |_|    |_|\\__, |\\___|"
    echo -e "              __/ |"
    echo -e "             |___/"
    echo -e "\033[0m\033[1;37m   🔧 북마크 삭제 🔧\033[0m"
    echo ""
    echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[37m삭제할 북마크를 선택하세요 (방향키 ↑↓, Enter, q: 취소):\033[0m"
    echo ""

    for i in "${!bookmarks[@]}"; do
      local num=$((i + 1))
      local display_group=""
      if [ "${groups[$i]}" != "없음" ] && [ -n "${groups[$i]}" ]; then
        display_group=" \033[90m[${groups[$i]}]\033[0m"
      fi

      if [ $i -eq $selected ]; then
        echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${bookmarks[$i]}\033[0m$display_group \033[37m◀\033[0m"
      else
        echo -e "  \033[90m[$num]\033[0m ${bookmarks[$i]}$display_group"
      fi
    done
  }

  draw_delete_screen

  while true; do
    read -rsn1 key

    if [[ $key == "" ]]; then
      local bookmark_to_delete="${bookmarks[$selected]}"

      clear
      echo "⚠️  '$bookmark_to_delete'을(를) 삭제하시겠습니까?"
      echo ""
      echo -n "정말 삭제하시겠습니까? (y/n): "
      read -r confirm
      if [[ "$confirm" != "y" ]]; then
        echo "취소되었습니다."
        return 0
      fi

      local updated
      updated=$(load_json | jq --arg name "$bookmark_to_delete" '
        .bookmarks |= map(select(.name != $name))
      ')

      save_json "$updated"
      echo -e "\033[1;37m🗑 삭제 완료:\033[0m $bookmark_to_delete"
      break
    fi

    if [[ $key == $'\e' ]]; then
      read -rsn2 key
      case $key in
        '[A')
          if [ $selected -gt 0 ]; then
            selected=$((selected - 1))
            draw_delete_screen
          fi
          ;;
        '[B')
          if [ $selected -lt $((total - 1)) ]; then
            selected=$((selected + 1))
            draw_delete_screen
          fi
          ;;
      esac
    fi

    if [[ $key == "q" ]]; then
      clear
      echo "취소됨"
      return 0
    fi
  done
}
