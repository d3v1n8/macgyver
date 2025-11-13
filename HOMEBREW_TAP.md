# Homebrew Tap 설정 가이드

MacGyver (mg)를 Homebrew tap으로 배포하는 방법입니다.

## 1. Homebrew Tap 저장소 생성

GitHub에 `homebrew-mg` 이름의 저장소를 생성해야 합니다.

```bash
# 저장소 이름은 반드시 homebrew-{name} 형식이어야 합니다
gh repo create hunwooha/homebrew-mg --public --description "Homebrew tap for MacGyver bookmark manager"
```

## 2. Tap 저장소 구조

```
homebrew-mg/
├── Formula/
│   └── mg.rb
└── README.md
```

## 3. Formula 파일 복사

현재 디렉토리의 `Formula/mg.rb` 파일을 tap 저장소로 복사합니다:

```bash
# Tap 저장소 클론
git clone https://github.com/hunwooha/homebrew-mg.git
cd homebrew-mg

# Formula 디렉토리 생성 및 파일 복사
mkdir -p Formula
cp /Users/hunwooha/mg/Formula/mg.rb Formula/

# 커밋 및 푸시
git add Formula/mg.rb
git commit -m "Add mg formula"
git push origin main
```

## 4. 메인 프로젝트 릴리즈 생성

사용자가 설치할 실제 mg 프로젝트의 릴리즈를 생성해야 합니다:

```bash
cd /Users/hunwooha/mg

# Git 저장소 초기화 (아직 안했다면)
git init
git add .
git commit -m "Initial commit"

# GitHub 저장소와 연결
git remote add origin https://github.com/hunwooha/mg.git
git branch -M main
git push -u origin main

# 릴리즈 태그 생성
git tag v1.0.0
git push origin v1.0.0

# GitHub에서 릴리즈 생성
gh release create v1.0.0 --title "v1.0.0" --notes "Initial release"
```

## 5. SHA256 해시 업데이트

릴리즈를 생성한 후, tarball의 SHA256 해시를 계산하여 Formula를 업데이트해야 합니다:

```bash
# tarball 다운로드 및 해시 계산
curl -sL https://github.com/hunwooha/mg/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256

# 출력된 해시 값을 Formula/mg.rb의 sha256 필드에 입력
# 예: sha256 "abc123def456..."
```

그런 다음 tap 저장소를 업데이트:

```bash
cd homebrew-mg
# Formula/mg.rb 파일의 sha256 값 수정
git add Formula/mg.rb
git commit -m "Update sha256 hash"
git push origin main
```

## 6. 사용자 설치 방법

이제 사용자들은 다음 명령어로 설치할 수 있습니다:

```bash
# Tap 추가 및 설치
brew tap hunwooha/mg
brew install mg

# 또는 한 번에
brew install hunwooha/mg/mg
```

## 7. Formula 업데이트

새 버전을 배포할 때:

1. mg 프로젝트에서 새 태그 생성 (예: v1.0.1)
2. GitHub 릴리즈 생성
3. 새 tarball의 SHA256 계산
4. tap 저장소의 Formula/mg.rb 업데이트:
   - url의 버전 번호 변경
   - sha256 해시 변경
5. 커밋 및 푸시

## 참고사항

- Formula 파일명과 클래스명은 소문자여야 합니다 (`mg.rb`, `class Mg`)
- Tap 저장소 이름은 반드시 `homebrew-` 접두사가 필요합니다
- sha256은 빈 문자열로 두면 안됩니다 - 반드시 실제 해시값 필요
- 의존성(jq)은 Homebrew가 자동으로 설치합니다

## 테스트

Formula가 올바른지 로컬에서 테스트:

```bash
# Formula 검증
brew install --build-from-source Formula/mg.rb

# 또는
brew audit --strict Formula/mg.rb
```
