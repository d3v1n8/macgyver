# 프로젝트 구조 안내

이 문서는 MacGyver (mg) 프로젝트의 완전한 구조를 설명합니다.

## 필요한 디렉토리 구조

프로젝트가 정상적으로 작동하려면 다음 구조가 필요합니다:

```
mg/
├── bin/
│   └── mg                    # 메인 실행 파일
├── lib/
│   ├── core/
│   │   ├── config.sh        # 환경 설정
│   │   └── store.sh         # JSON 저장소 관리
│   └── commands/
│       ├── help.sh          # 도움말 명령어
│       ├── list.sh          # 북마크 목록 (대화형)
│       ├── add.sh           # 북마크 추가 (대화형)
│       ├── delete.sh        # 북마크 삭제 (대화형)
│       ├── open.sh          # 브라우저로 열기
│       ├── search.sh        # 빠른 검색
│       └── groups.sh        # 그룹 관리 (대화형)
├── Formula/
│   └── mg.rb                # Homebrew Formula
├── .gitignore
├── LICENSE
├── README.md
├── HOMEBREW_TAP.md          # Tap 설정 가이드
├── install.sh               # 설치 스크립트
└── PROJECT_NOTES.md         # 이 문서
```

## 현재 상태

현재 디렉토리에는 다음 파일들이 준비되어 있습니다:

- ✅ README.md - 프로젝트 문서
- ✅ LICENSE - MIT 라이선스
- ✅ .gitignore - Git 제외 파일
- ✅ install.sh - 설치 스크립트
- ✅ Formula/mg.rb - Homebrew Formula
- ✅ HOMEBREW_TAP.md - Tap 설정 가이드
- ⏳ bin/mg - 메인 실행 파일 (필요)
- ⏳ lib/ - 핵심 라이브러리들 (필요)

## 다음 단계

1. **bin/mg 파일 복사**: 이전에 작성한 메인 실행 파일을 bin/ 디렉토리에 배치
2. **lib/ 디렉토리 복사**: core/와 commands/ 하위 디렉토리와 모든 스크립트 파일 배치
3. **Git 저장소 초기화**:
   ```bash
   cd /Users/hunwooha/mg
   git init
   git add .
   git commit -m "Initial commit: MacGyver bookmark manager"
   ```

4. **GitHub 저장소 생성 및 푸시**:
   ```bash
   gh repo create hunwooha/mg --public --description "시크하고 강력한 CLI 북마크 관리 도구"
   git remote add origin https://github.com/hunwooha/mg.git
   git branch -M main
   git push -u origin main
   ```

5. **Homebrew Tap 저장소 설정**: HOMEBREW_TAP.md 가이드를 참조하여 설정

## 핵심 기능

- **모노크롬 디자인**: 눈에 편한 시크한 흑백 인터페이스
- **방향키 네비게이션**: 모든 명령어에서 대화형 선택 지원
- **빠른 검색**: `mg <키워드>` 한 번에 북마크/그룹 검색
- **그룹 관리**: 북마크를 그룹으로 체계적으로 정리
- **간편한 Alias**: `mgb`, `mgg` 숏컷 제공

## 데이터 저장

모든 북마크는 `~/.mg/bookmarks.json`에 JSON 형식으로 저장됩니다:

```json
{
  "bookmarks": [
    {
      "id": 1,
      "name": "GitHub",
      "url": "https://github.com",
      "group": "개발"
    }
  ],
  "groups": ["개발", "게임", "뉴스"]
}
```

## 문의

문제가 있거나 개선 사항이 있다면 GitHub Issues에 등록해주세요.
