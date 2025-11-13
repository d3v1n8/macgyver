#!/bin/bash

# List 명령어

bm_list() {
  local group_filter=""
  local interactive=true

  for arg in "$@"; do
    case $arg in
      --group*)
        group_filter=$(echo "$arg" | cut -d= -f2)
        ;;
      --no-interactive)
        interactive=false
        ;;
    esac
  done

  local result
  result=$(load_json | jq -r --arg g "$group_filter" '
    .bookmarks
    | map(select($g == "" or .group == $g))
    | to_entries
    | .[]
    | "[" + ((.key + 1)|tostring) + "] " + .value.name + "  " + (
        if (.value.url | contains("://")) then
          (.value.url | split("://")[1] | split("/")[0])
        else
          (.value.url | split("/")[0])
        end
      )
  ')

  if [ -z "$result" ]; then
    if [ -n "$group_filter" ]; then
      echo "📭 해당 그룹에 북마크가 없습니다."
    else
      echo "📭 저장된 북마크가 없습니다. 'mgb add' 명령으로 북마크를 추가해보세요."
    fi
    return
  fi

  # 대화형 모드가 아닐 때만 결과 출력
  if [ "$interactive" = false ]; then
    echo "$result"
    return
  fi

  # 대화형 모드
  # 북마크 이름 배열 생성
  local names=()
  while IFS= read -r line; do
    local name=$(echo "$line" | sed 's/\[[0-9]*\] \(.*\)  .*/\1/')
    names+=("$name")
  done <<< "$result"

  local total=${#names[@]}
  local selected=0  # 0-based index

  # 메뉴 전체 그리기 함수
  draw_full_menu() {
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
    echo -e "\033[0m   MacGyver Bookmark Manager"
    echo ""
    echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[90m방향키 ↑↓ 선택  Enter 열기  q 취소\033[0m"
    echo ""

    for i in "${!names[@]}"; do
      local num=$((i + 1))
      if [ $i -eq $selected ]; then
        echo -e "  \033[90m$num\033[0m \033[1;37m${names[$i]}\033[0m \033[37m→\033[0m"
      else
        echo -e "  \033[90m$num\033[0m \033[37m${names[$i]}\033[0m"
      fi
    done
  }

  # 초기 메뉴 표시
  draw_full_menu

  # 키 입력 처리
  while true; do
    read -rsn1 key

    # Enter
    if [[ $key == "" ]]; then
      clear
      bm_open "${names[$selected]}"
      break
    fi

    # 숫자 직접 입력
    if [[ $key =~ ^[0-9]$ ]]; then
      echo -n "$key"
      read -r rest
      local input="$key$rest"
      if [[ "$input" =~ ^[0-9]+$ ]] && [ "$input" -ge 1 ] && [ "$input" -le "$total" ]; then
        local index=$((input - 1))
        clear
        bm_open "${names[$index]}"
        break
      else
        clear
        echo "❌ 올바른 번호를 입력하세요."
        break
      fi
    fi

    # ESC sequence (방향키)
    if [[ $key == $'\e' ]]; then
      read -rsn2 key
      case $key in
        '[A')  # 위쪽 화살표
          if [ $selected -gt 0 ]; then
            selected=$((selected - 1))
            draw_full_menu
          fi
          ;;
        '[B')  # 아래쪽 화살표
          if [ $selected -lt $((total - 1)) ]; then
            selected=$((selected + 1))
            draw_full_menu
          fi
          ;;
      esac
    fi

    # q로 종료
    if [[ $key == "q" ]]; then
      clear
      echo "취소됨"
      break
    fi
  done
}
