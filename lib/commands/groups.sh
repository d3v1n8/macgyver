#!/bin/bash

# Groups 명령어

# 모든 그룹 목록 출력 (대화형)
bm_groups() {
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
  echo -e "\033[0m\033[1;37m   🔧 그룹 목록 🔧\033[0m"
  echo ""
  echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  # 그룹 목록 가져오기
  local groups_json=$(load_json | jq -r '.groups[]? // empty')
  local groups=()
  local counts=()

  while IFS= read -r group; do
    if [ -n "$group" ]; then
      groups+=("$group")
      local count=$(load_json | jq -r --arg g "$group" '[.bookmarks[] | select(.group == $g)] | length')
      counts+=("$count")
    fi
  done <<< "$groups_json"

  if [ ${#groups[@]} -eq 0 ]; then
    echo "📭 생성된 그룹이 없습니다. 'mgg add <그룹명>' 명령으로 그룹을 추가해보세요."
    return 0
  fi

  local selected=0
  local total=${#groups[@]}

  # 그룹 목록 화면 그리기
  draw_groups_screen() {
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
    echo -e "\033[0m\033[1;37m   🔧 그룹 목록 🔧\033[0m"
    echo ""
    echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[37m그룹을 선택하세요 (방향키 ↑↓, Enter로 북마크 보기, q: 취소):\033[0m"
    echo ""

    for i in "${!groups[@]}"; do
      local num=$((i + 1))
      if [ $i -eq $selected ]; then
        echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${groups[$i]}\033[0m \033[90m(${counts[$i]}개)\033[0m \033[37m◀\033[0m"
      else
        echo -e "  \033[90m[$num]\033[0m ${groups[$i]} \033[90m(${counts[$i]}개)\033[0m"
      fi
    done
  }

  draw_groups_screen

  # 키 입력 처리
  while true; do
    read -rsn1 key

    if [[ $key == "" ]]; then
      # Enter - 해당 그룹의 북마크 목록 보기
      local selected_group="${groups[$selected]}"

      # 해당 그룹의 북마크 가져오기
      local bookmarks_json=$(load_json | jq -r --arg g "$selected_group" '
        .bookmarks[] | select(.group == $g) | .name
      ')

      local bookmarks=()
      while IFS= read -r bm; do
        if [ -n "$bm" ]; then
          bookmarks+=("$bm")
        fi
      done <<< "$bookmarks_json"

      if [ ${#bookmarks[@]} -eq 0 ]; then
        clear
        echo "📭 '$selected_group' 그룹에 북마크가 없습니다."
        echo ""
        echo "아무 키나 눌러 돌아가기..."
        read -rsn1
        draw_groups_screen
        continue
      fi

      # 북마크 선택 화면
      local bm_selected=0
      local bm_total=${#bookmarks[@]}

      draw_bookmarks_screen() {
        clear
        echo -e "\033[1;37m📁 그룹: $selected_group\033[0m"
        echo ""
        echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\033[37m북마크를 선택하세요 (방향키 ↑↓, Enter로 열기, q: 뒤로):\033[0m"
        echo ""

        for i in "${!bookmarks[@]}"; do
          local num=$((i + 1))
          if [ $i -eq $bm_selected ]; then
            echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${bookmarks[$i]}\033[0m \033[37m◀\033[0m"
          else
            echo -e "  \033[90m[$num]\033[0m ${bookmarks[$i]}"
          fi
        done
      }

      draw_bookmarks_screen

      # 북마크 선택 키 입력
      while true; do
        read -rsn1 bm_key

        if [[ $bm_key == "" ]]; then
          # Enter - 북마크 열기
          clear
          bm_open "${bookmarks[$bm_selected]}"
          return 0
        fi

        if [[ $bm_key == $'\e' ]]; then
          read -rsn2 bm_key
          case $bm_key in
            '[A')  # 위
              if [ $bm_selected -gt 0 ]; then
                bm_selected=$((bm_selected - 1))
                draw_bookmarks_screen
              fi
              ;;
            '[B')  # 아래
              if [ $bm_selected -lt $((bm_total - 1)) ]; then
                bm_selected=$((bm_selected + 1))
                draw_bookmarks_screen
              fi
              ;;
          esac
        fi

        if [[ $bm_key == "q" ]]; then
          # 그룹 목록으로 돌아가기
          draw_groups_screen
          break
        fi
      done
    fi

    if [[ $key == $'\e' ]]; then
      read -rsn2 key
      case $key in
        '[A')  # 위
          if [ $selected -gt 0 ]; then
            selected=$((selected - 1))
            draw_groups_screen
          fi
          ;;
        '[B')  # 아래
          if [ $selected -lt $((total - 1)) ]; then
            selected=$((selected + 1))
            draw_groups_screen
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

# 그룹 생성 및 북마크 관리
bm_group_add() {
  local group="$1"

  # 인자가 있으면 바로 그룹 생성 (기존 방식)
  if [ -n "$group" ]; then
    # 이미 존재하는지 확인
    local exists=$(load_json | jq -r --arg g "$group" '.groups[]? // empty | select(. == $g)')

    if [ -n "$exists" ]; then
      echo "⚠️  그룹 '$group'은 이미 존재합니다."
      return 1
    fi

    # groups 배열이 없으면 생성하고, 그룹 추가
    local updated
    updated=$(load_json | jq --arg g "$group" '
      if .groups then
        .groups += [$g]
      else
        .groups = [$g]
      end
    ')

    save_json "$updated"

    echo -e "\033[1;37m✅ 그룹 생성 완료:\033[0m $group"
    echo -e "   💡 북마크 추가 시 이 그룹을 사용하세요."
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
  echo -e "\033[0m\033[1;37m   🔧 그룹 관리 🔧\033[0m"
  echo ""
  echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  # 기존 그룹 목록 가져오기
  local groups_json=$(load_json | jq -r '.groups[]? // empty')
  local groups=()

  while IFS= read -r g; do
    if [ -n "$g" ]; then
      groups+=("$g")
    fi
  done <<< "$groups_json"

  # "새 그룹 만들기" 옵션 추가
  groups+=("+ 새 그룹 만들기")

  local total=${#groups[@]}
  local selected=0

  if [ "$total" -eq 0 ] || [ "$total" -eq 1 ]; then
    echo "📭 생성된 그룹이 없습니다."
    echo ""
    echo -n -e "\033[37m새로운 그룹명 => \033[0m"
    read -r new_group

    if [ -z "$new_group" ]; then
      echo "❌ 그룹명은 필수입니다."
      return 1
    fi

    local updated
    updated=$(load_json | jq --arg g "$new_group" '
      if .groups then
        .groups += [$g]
      else
        .groups = [$g]
      end
    ')
    save_json "$updated"

    echo -e "\033[1;37m✅ 그룹 생성 완료:\033[0m $new_group"
    group="$new_group"
  else
    echo -e "\033[37m그룹을 선택하세요 (방향키 ↑↓, Enter):\033[0m"
    echo ""

    # 메뉴 그리기 함수
    draw_group_menu() {
      for i in "${!groups[@]}"; do
        local num=$((i + 1))
        if [ $i -eq $selected ]; then
          echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${groups[$i]}\033[0m \033[37m◀\033[0m"
        else
          echo -e "  \033[90m[$num]\033[0m ${groups[$i]}"
        fi
      done
    }

    # 화면 그리기
    draw_screen() {
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
      echo -e "\033[0m\033[1;37m   🔧 그룹 관리 🔧\033[0m"
      echo ""
      echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
      echo -e "\033[37m그룹을 선택하세요 (방향키 ↑↓, Enter, q: 취소):\033[0m"
      echo ""
      draw_group_menu
    }

    draw_screen

    # 키 입력 처리
    while true; do
      read -rsn1 key

      if [[ $key == "" ]]; then
        # Enter - 그룹 선택됨
        if [ "${groups[$selected]}" = "+ 새 그룹 만들기" ]; then
          clear
          echo -n -e "\033[37m새로운 그룹명 => \033[0m"
          read -r new_group

          if [ -z "$new_group" ]; then
            echo "❌ 그룹명은 필수입니다."
            return 1
          fi

          local updated
          updated=$(load_json | jq --arg g "$new_group" '
            if .groups then
              .groups += [$g]
            else
              .groups = [$g]
            end
          ')
          save_json "$updated"

          echo -e "\033[1;37m✅ 그룹 생성 완료:\033[0m $new_group"
          group="$new_group"
        else
          group="${groups[$selected]}"
        fi
        break
      fi

      if [[ $key == $'\e' ]]; then
        read -rsn2 key
        case $key in
          '[A')  # 위
            if [ $selected -gt 0 ]; then
              selected=$((selected - 1))
              draw_screen
            fi
            ;;
          '[B')  # 아래
            if [ $selected -lt $((total - 1)) ]; then
              selected=$((selected + 1))
              draw_screen
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
  fi

  # 그룹이 선택됨 - 다음 단계
  clear
  echo -e "\033[1;37m선택된 그룹:\033[0m $group"
  echo ""
  echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
  echo -e "\033[37m다음 작업을 선택하세요:\033[0m"
  echo ""
  echo -e "  \033[1;37m[1]\033[0m \033[1;37m새로운 북마크 등록\033[0m \033[37m◀\033[0m"
  echo -e "  \033[90m[2]\033[0m 기존 북마크를 이 그룹에 추가"
  echo ""

  local action_selected=0
  local actions=("새로운 북마크 등록" "기존 북마크를 이 그룹에 추가")

  draw_action_screen() {
    clear
    echo -e "\033[1;37m선택된 그룹:\033[0m $group"
    echo ""
    echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[37m다음 작업을 선택하세요 (방향키 ↑↓, Enter, q: 취소):\033[0m"
    echo ""

    for i in {0..1}; do
      local num=$((i + 1))
      if [ $i -eq $action_selected ]; then
        echo -e "  \033[1;37m[$num]\033[0m \033[1;37m${actions[$i]}\033[0m \033[37m◀\033[0m"
      else
        echo -e "  \033[90m[$num]\033[0m ${actions[$i]}"
      fi
    done
  }

  draw_action_screen

  while true; do
    read -rsn1 key

    if [[ $key == "" ]]; then
      if [ $action_selected -eq 0 ]; then
        # 새로운 북마크 등록
        clear
        echo -e "\033[1;37m📝 새로운 북마크 등록 (그룹: $group)\033[0m"
        echo ""

        echo -n -e "\033[37m링크명 => \033[0m"
        read -r name

        if [ -z "$name" ]; then
          echo "❌ 링크명은 필수입니다."
          return 1
        fi

        echo -n -e "\033[37m링크 URL => \033[0m"
        read -r url

        if [ -z "$url" ]; then
          echo "❌ URL은 필수입니다."
          return 1
        fi

        local id=$(generate_id)
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
        echo -e "\033[1;37m✅ 북마크 추가 완료:\033[0m $name → $group"
      else
        # 기존 북마크를 이 그룹에 추가
        clear
        echo -e "\033[1;37m📎 기존 북마크를 '$group' 그룹에 추가\033[0m"
        echo ""

        # 그룹이 없는 북마크 목록
        local ungrouped_json=$(load_json | jq -r '.bookmarks[] | select(.group == "" or .group == null) | .name')
        local bookmarks_array=()

        while IFS= read -r bm; do
          if [ -n "$bm" ]; then
            bookmarks_array+=("$bm")
          fi
        done <<< "$ungrouped_json"

        if [ ${#bookmarks_array[@]} -eq 0 ]; then
          echo "📭 그룹이 없는 북마크가 없습니다."
          return 0
        fi

        local bm_selected=0
        local bm_total=${#bookmarks_array[@]}

        # 북마크 선택 화면 그리기
        draw_bookmark_screen() {
          clear
          echo -e "\033[1;37m📎 기존 북마크를 '$group' 그룹에 추가\033[0m"
          echo ""
          echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
          echo -e "\033[37m북마크를 선택하세요 (방향키 ↑↓, Enter, q: 취소):\033[0m"
          echo ""

          for i in "${!bookmarks_array[@]}"; do
            local num=$((i + 1))
            if [ $i -eq $bm_selected ]; then
              echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${bookmarks_array[$i]}\033[0m \033[37m◀\033[0m"
            else
              echo -e "  \033[90m[$num]\033[0m ${bookmarks_array[$i]}"
            fi
          done
        }

        draw_bookmark_screen

        # 키 입력 처리
        while true; do
          read -rsn1 key

          if [[ $key == "" ]]; then
            # Enter - 북마크 선택됨
            local bookmark_name="${bookmarks_array[$bm_selected]}"

            # 북마크에 그룹 할당
            local updated
            updated=$(load_json | jq --arg name "$bookmark_name" --arg group "$group" '
              .bookmarks |= map(
                if .name == $name then
                  .group = $group
                else
                  .
                end
              )
            ')

            save_json "$updated"
            clear
            echo -e "\033[1;37m✅ '$bookmark_name'을(를) '$group' 그룹에 추가했습니다.\033[0m"
            break
          fi

          if [[ $key == $'\e' ]]; then
            read -rsn2 key
            case $key in
              '[A')  # 위
                if [ $bm_selected -gt 0 ]; then
                  bm_selected=$((bm_selected - 1))
                  draw_bookmark_screen
                fi
                ;;
              '[B')  # 아래
                if [ $bm_selected -lt $((bm_total - 1)) ]; then
                  bm_selected=$((bm_selected + 1))
                  draw_bookmark_screen
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
      fi
      break
    fi

    if [[ $key == $'\e' ]]; then
      read -rsn2 key
      case $key in
        '[A')  # 위
          action_selected=0
          draw_action_screen
          ;;
        '[B')  # 아래
          action_selected=1
          draw_action_screen
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

# 그룹 삭제 (대화형)
bm_group_delete() {
  local group="$1"

  # 인자가 있으면 바로 삭제 (기존 방식)
  if [ -n "$group" ]; then
    local exists=$(load_json | jq -r --arg g "$group" '.groups[]? // empty | select(. == $g)')

    if [ -z "$exists" ]; then
      echo "❌ 그룹 '$group'을 찾을 수 없습니다."
      return 1
    fi

    local count=$(load_json | jq -r --arg g "$group" '[.bookmarks[] | select(.group == $g)] | length')

    if [ "$count" -gt 0 ]; then
      echo "⚠️  그룹 '$group'에 $count개의 북마크가 있습니다."
      echo -n "정말 삭제하시겠습니까? (y/n): "
      read -r confirm
      if [[ "$confirm" != "y" ]]; then
        echo "취소되었습니다."
        return 0
      fi
    fi

    local updated
    updated=$(load_json | jq --arg g "$group" '
      .groups = (.groups // [] | map(select(. != $g)))
    ')

    save_json "$updated"
    echo -e "\033[1;37m✅ 그룹 삭제 완료:\033[0m $group"
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
  echo -e "\033[0m\033[1;37m   🔧 그룹 삭제 🔧\033[0m"
  echo ""
  echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"

  # 그룹 목록 가져오기
  local groups_json=$(load_json | jq -r '.groups[]? // empty')
  local groups=()
  local counts=()

  while IFS= read -r g; do
    if [ -n "$g" ]; then
      groups+=("$g")
      local count=$(load_json | jq -r --arg grp "$g" '[.bookmarks[] | select(.group == $grp)] | length')
      counts+=("$count")
    fi
  done <<< "$groups_json"

  if [ ${#groups[@]} -eq 0 ]; then
    echo "📭 삭제할 그룹이 없습니다."
    return 0
  fi

  local selected=0
  local total=${#groups[@]}

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
    echo -e "\033[0m\033[1;37m   🔧 그룹 삭제 🔧\033[0m"
    echo ""
    echo -e "\033[90m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
    echo -e "\033[37m삭제할 그룹을 선택하세요 (방향키 ↑↓, Enter, q: 취소):\033[0m"
    echo ""

    for i in "${!groups[@]}"; do
      local num=$((i + 1))
      if [ $i -eq $selected ]; then
        echo -e "  \033[1;37m[\033[1;37m$num\033[1;37m]\033[0m \033[1;37m${groups[$i]}\033[0m \033[90m(${counts[$i]}개)\033[0m \033[37m◀\033[0m"
      else
        echo -e "  \033[90m[$num]\033[0m ${groups[$i]} \033[90m(${counts[$i]}개)\033[0m"
      fi
    done
  }

  draw_delete_screen

  while true; do
    read -rsn1 key

    if [[ $key == "" ]]; then
      local group_to_delete="${groups[$selected]}"
      local count="${counts[$selected]}"

      clear
      if [ "$count" -gt 0 ] 2>/dev/null; then
        echo "⚠️  그룹 '$group_to_delete'에 ${count}개의 북마크가 있습니다."
        echo ""
        echo -n "정말 삭제하시겠습니까? (y/n): "
        read -r confirm
        if [[ "$confirm" != "y" ]]; then
          echo "취소되었습니다."
          return 0
        fi
      else
        echo -n "그룹 '$group_to_delete'을(를) 삭제하시겠습니까? (y/n): "
        read -r confirm
        if [[ "$confirm" != "y" ]]; then
          echo "취소되었습니다."
          return 0
        fi
      fi

      local updated
      updated=$(load_json | jq --arg g "$group_to_delete" '
        .groups = (.groups // [] | map(select(. != $g)))
      ')

      save_json "$updated"
      echo -e "\033[1;37m✅ 그룹 삭제 완료:\033[0m $group_to_delete"
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

# 특정 그룹의 북마크 목록
bm_group_list() {
  bm_list --group="$1"
}
