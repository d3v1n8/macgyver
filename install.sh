#!/bin/bash

set -e

echo "MacGyver Bookmark Manager 설치 시작..."
echo ""

# jq 설치 확인
if ! command -v jq &> /dev/null; then
    echo "jq를 설치합니다..."
    if command -v brew &> /dev/null; then
        brew install jq
    else
        echo "❌ Homebrew가 설치되어 있지 않습니다."
        echo "jq를 수동으로 설치해주세요: https://stedolan.github.io/jq/"
        exit 1
    fi
fi

# 설치 디렉토리
INSTALL_DIR="$HOME/mg"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 이미 설치되어 있는 경우
if [ "$SCRIPT_DIR" != "$INSTALL_DIR" ]; then
    echo "파일을 $INSTALL_DIR로 복사합니다..."
    mkdir -p "$INSTALL_DIR"
    cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"
fi

# 실행 권한 설정
chmod +x "$INSTALL_DIR/bin/mg"

# 데이터 디렉토리 생성
mkdir -p "$HOME/.mg"
if [ ! -f "$HOME/.mg/bookmarks.json" ]; then
    echo '{"bookmarks":[],"groups":[]}' > "$HOME/.mg/bookmarks.json"
fi

# Shell 설정 파일 확인
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
fi

# Alias 추가
if [ -n "$SHELL_RC" ]; then
    # 기존 alias 제거
    sed -i '' '/alias mg=/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '' '/alias mgb=/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '' '/alias mgg=/d' "$SHELL_RC" 2>/dev/null || true

    # 새 alias 추가
    echo "" >> "$SHELL_RC"
    echo "# MacGyver Bookmark Manager" >> "$SHELL_RC"
    echo "alias mg=\"\$HOME/mg/bin/mg\"" >> "$SHELL_RC"
    echo "alias mgb=\"\$HOME/mg/bin/mg b\"" >> "$SHELL_RC"
    echo "alias mgg=\"\$HOME/mg/bin/mg g\"" >> "$SHELL_RC"

    echo "✅ $SHELL_RC에 alias가 추가되었습니다."
else
    echo "⚠️  Shell 설정 파일을 찾을 수 없습니다."
    echo "다음 라인을 수동으로 추가해주세요:"
    echo ""
    echo "alias mg=\"\$HOME/mg/bin/mg\""
    echo "alias mgb=\"\$HOME/mg/bin/mg b\""
    echo "alias mgg=\"\$HOME/mg/bin/mg g\""
fi

echo ""
echo "✅ 설치 완료!"
echo ""
echo "사용법:"
echo "  mg <검색어>    - 빠른 검색"
echo "  mgb list       - 북마크 목록"
echo "  mgb add        - 북마크 추가"
echo "  mgg list       - 그룹 목록"
echo "  mg --help      - 도움말"
echo ""
echo "터미널을 재시작하거나 다음 명령어를 실행하세요:"
echo "  source $SHELL_RC"
