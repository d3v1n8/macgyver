# MacGyver Bookmark Manager

CLI 북마크 관리 도구

## Features

- 🔖 **북마크 관리** - 빠르게 북마크를 추가, 삭제, 검색
- 📁 **그룹 관리** - 북마크를 그룹으로 조직화
- ⚡ **빠른 검색** - `mg <키워드>`로 즉시 검색
- ⌨️  **대화형 UI** - 방향키로 선택하고 Enter로 실행
- 🎨 **시크한 디자인** - 눈에 편한 모노톤 인터페이스

## Installation

### Homebrew (권장)

```bash
brew tap d3v1n8/macgyver/mg
brew install mg
```

### Manual Installation

```bash
git clone https://github.com/d3v1n8/macgyver.git
cd mg
./install.sh
```

## Usage

### 빠른 검색
```bash
mg github          # 북마크/그룹 통합 검색
```

### 북마크 관리
```bash
mgb list           # 북마크 목록 (대화형)
mgb add            # 북마크 추가 (대화형)
mgb delete         # 북마크 삭제 (대화형)
mgb open <name>    # 브라우저로 열기
```

### 그룹 관리
```bash
mgg list           # 그룹 목록 (대화형)
mgg add            # 그룹 추가 (대화형)
mgg delete         # 그룹 삭제 (대화형)
```

## Data Storage

북마크 데이터는 `~/.mg/bookmarks.json`에 저장됩니다.

## Requirements

- macOS
- Bash
- jq (자동으로 설치됨)

## License

MIT
