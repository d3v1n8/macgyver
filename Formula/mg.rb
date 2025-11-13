class Mg < Formula
  desc "시크하고 강력한 CLI 북마크 관리 도구"
  homepage "https://github.com/d3v1n8/macgyver"
  url "https://github.com/d3v1n8/macgyver/archive/refs/tags/v1.0.0.tar.gz"
  sha256 ""  # 실제 릴리즈 생성 후 업데이트 필요
  license "MIT"

  depends_on "jq"

  def install
    # bin 디렉토리가 있다면 설치
    if File.directory?("bin")
      bin.install "bin/mg"
    end

    # lib 디렉토리 설치
    if File.directory?("lib")
      prefix.install "lib"
    end

    # 데이터 디렉토리 생성
    (var/"mg").mkpath
  end

  def post_install
    # 초기 데이터 파일 생성
    mg_dir = "#{ENV["HOME"]}/.mg"
    mg_db = "#{mg_dir}/bookmarks.json"

    unless File.exist?(mg_dir)
      system "mkdir", "-p", mg_dir
    end

    unless File.exist?(mg_db)
      File.write(mg_db, '{"bookmarks":[],"groups":[]}')
    end
  end

  def caveats
    <<~EOS
      MacGyver Bookmark Manager가 설치되었습니다!

      다음 alias를 shell 설정 파일에 추가하세요:

        alias mg="#{opt_bin}/mg"
        alias mgb="#{opt_bin}/mg b"
        alias mgg="#{opt_bin}/mg g"

      또는 자동으로 추가하려면:

        echo 'alias mg="#{opt_bin}/mg"' >> ~/.zshrc
        echo 'alias mgb="#{opt_bin}/mg b"' >> ~/.zshrc
        echo 'alias mgg="#{opt_bin}/mg g"' >> ~/.zshrc
        source ~/.zshrc

      사용법:
        mg <검색어>    - 빠른 검색
        mgb list       - 북마크 목록
        mgb add        - 북마크 추가
        mgg list       - 그룹 목록
        mg --help      - 도움말
    EOS
  end

  test do
    system "#{bin}/mg", "--help"
  end
end
