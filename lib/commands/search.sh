#!/bin/bash

# Search 명령어

bm_search() {
  local keyword="$1"
  load_json | jq -r --arg k "$keyword" '
    .bookmarks[] | select(.name | contains($k)) |
    "[" + (.id|tostring) + "] " + .name + "  " + .url
  '
}

# 통합 검색 (대화형)
bm_quick_search() {
  local keyword="$1"

  if [ -z "$keyword" ]; then
    echo "❌ 검색어를 입력하세요. 사용법: mg <검색어>"
    return 1
  fi

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
  echo -e "\033[0m\033[1;37m   🔧 검색: \"$keyword\" 🔧\033[0m"
  echo ""
  echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  # 북마크 검색
  local bookmarks_json=$(load_json | jq -r --arg k "$keyword" '
    .bookmarks[] | select(.name | ascii_downcase | contains($k | ascii_downcase)) | .name
  ')
  local bookmarks=()
  local bookmark_groups=()

  while IFS= read -r bm; do
    if [ -n "$bm" ]; then
      bookmarks+=("$bm")
      local group=$(load_json | jq -r --arg name "$bm" '.bookmarks[] | select(.name == $name) | .group // ""')
      bookmark_groups+=("$group")
    fi
  done <<< "$bookmarks_json"

  # 그룹 검색
  local groups_json=$(load_json | jq -r --arg k "$keyword" '
    .groups[]? // empty | select(. | ascii_downcase | contains($k | ascii_downcase))
  ')
  local groups=()
  local group_counts=()

  while IFS= read -r grp; do
    if [ -n "$grp" ]; then
      groups+=("$grp")
      local count=$(load_json | jq -r --arg g "$grp" '[.bookmarks[] | select(.group == $g)] | length')
      group_counts+=("$count")
    fi
  done <<< "$groups_json"

  # 결과 합치기
  local results=()
  local result_types=()  # "bookmark" or "group"
  local result_extras=()  # 그룹 정보 또는 북마크 개수

  for i in "${!bookmarks[@]}"; do
    results+=("${bookmarks[$i]}")
    result_types+=("bookmark")
    result_extras+=("${bookmark_groups[$i]}")
  done

  for i in "${!groups[@]}"; do
    results+=("${groups[$i]}")
    result_types+=("group")
    result_extras+=("${group_counts[$i]}")
  done

  if [ ${#results[@]} -eq 0 ]; then
    echo "📭 '$keyword'에 대한 검색 결과가 없습니다."
    return 0
  fi

  local selected=0
  local total=${#results[@]}

  draw_search_screen() {
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
    echo -e "\033[0m\033[1;37m   🔧 검색: \"$keyword\" 🔧\033[0m"
    echo ""
    echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[37m검색 결과 (방향키 ↑↓, Enter, q: 취소):\033[0m"
    echo ""

    for i in "${!results[@]}"; do
      local num=$((i + 1))
      local type_icon=""
      local extra_info=""

      if [ "${result_types[$i]}" = "bookmark" ]; then
        type_icon="🔖"
        if [ -n "${result_extras[$i]}" ]; then
          extra_info=" \033[90m[${result_extras[$i]}]\033[0m"
        fi
      else
        type_icon="📁"
        extra_info=" \033[90m(${result_extras[$i]}개)\033[0m"
      fi

      if [ $i -eq $selected ]; then
        echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m $type_icon \033[1;37m${results[$i]}\033[0m$extra_info \033[37m◀\033[0m"
      else
        echo -e "  \033[90m[$num]\033[0m $type_icon ${results[$i]}$extra_info"
      fi
    done
  }

  draw_search_screen

  while true; do
    read -rsn1 key

    if [[ $key == "" ]]; then
      if [ "${result_types[$selected]}" = "bookmark" ]; then
        # 북마크 열기
        clear
        bm_open "${results[$selected]}"
        return 0
      else
        # 그룹의 북마크 목록 보기
        local selected_group="${results[$selected]}"

        # 해당 그룹의 북마크 가져오기
        local group_bookmarks_json=$(load_json | jq -r --arg g "$selected_group" '
          .bookmarks[] | select(.group == $g) | .name
        ')

        local group_bookmarks=()
        while IFS= read -r bm; do
          if [ -n "$bm" ]; then
            group_bookmarks+=("$bm")
          fi
        done <<< "$group_bookmarks_json"

        if [ ${#group_bookmarks[@]} -eq 0 ]; then
          clear
          echo "📭 '$selected_group' 그룹에 북마크가 없습니다."
          return 0
        fi

        # 북마크 선택 화면
        local bm_selected=0
        local bm_total=${#group_bookmarks[@]}

        draw_group_bookmarks_screen() {
          clear
          echo -e "\033[1;37m📁 그룹: $selected_group\033[0m"
          echo ""
          echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
          echo -e "\033[37m북마크를 선택하세요 (방향키 ↑↓, Enter로 열기, q: 뒤로):\033[0m"
          echo ""

          for i in "${!group_bookmarks[@]}"; do
            local num=$((i + 1))
            if [ $i -eq $bm_selected ]; then
              echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${group_bookmarks[$i]}\033[0m \033[37m◀\033[0m"
            else
              echo -e "  \033[90m[$num]\033[0m ${group_bookmarks[$i]}"
            fi
          done
        }

        draw_group_bookmarks_screen

        while true; do
          read -rsn1 bm_key

          if [[ $bm_key == "" ]]; then
            clear
            bm_open "${group_bookmarks[$bm_selected]}"
            return 0
          fi

          if [[ $bm_key == $'\e' ]]; then
            read -rsn2 bm_key
            case $bm_key in
              '[A')
                if [ $bm_selected -gt 0 ]; then
                  bm_selected=$((bm_selected - 1))
                  draw_group_bookmarks_screen
                fi
                ;;
              '[B')
                if [ $bm_selected -lt $((bm_total - 1)) ]; then
                  bm_selected=$((bm_selected + 1))
                  draw_group_bookmarks_screen
                fi
                ;;
            esac
          fi

          if [[ $bm_key == "q" ]]; then
            draw_search_screen
            break
          fi
        done
      fi
    fi

    if [[ $key == $'\e' ]]; then
      read -rsn2 key
      case $key in
        '[A')
          if [ $selected -gt 0 ]; then
            selected=$((selected - 1))
            draw_search_screen
          fi
          ;;
        '[B')
          if [ $selected -lt $((total - 1)) ]; then
            selected=$((selected + 1))
            draw_search_screen
          fi
          ;;
      esac
    fi

    if [[ $key == "q" ]]; then
      clear
      return 0
    fi
  done
}
