class Lazyspotify < Formula
  desc "Terminal Spotify client bundled with a patched go-librespot daemon"
  homepage "https://github.com/dubeyKartikay/lazyspotify"
  url "https://github.com/dubeyKartikay/lazyspotify/releases/download/v0.1.0/lazyspotify-v0.1.0-src.tar.gz"
  sha256 "207f5fb4725ef1483a73363fe4d7f030f238776db7bc06a8ba8f4ed2ca421020"
  license all_of: ["MIT", "GPL-3.0-only"]

  depends_on "flac" => :build
  depends_on "go" => :build
  depends_on "libogg" => :build
  depends_on "libvorbis" => :build
  depends_on "pkgconf" => :build

  def install
    daemon_path = opt_libexec/"lazyspotify-librespot"
    main_ldflags = [
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Version=0.1.0",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Commit=8f7ba68950aaf758a16aa543ece62a234632e0cc",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.BuildDate=2026-04-13T11:55:07Z",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.PackagedDaemonPath=#{daemon_path}",
    ]

    system "go", "build", "-trimpath", "-buildvcs=false",
      "-ldflags", main_ldflags.join(" "),
      "-o", bin/"lazyspotify",
      "./cmd/lazyspotify"

    cd buildpath/"third_party/go-librespot" do
      system "go", "build", "-trimpath", "-buildvcs=false",
        "-ldflags", "-X github.com/devgianlu/go-librespot.version=v0.7.1.1",
        "-o", libexec/"lazyspotify-librespot",
        "./cmd/daemon"
    end
  end

  test do
    version_output = shell_output("#{bin}/lazyspotify version")
    assert_match "version=0.1.0", version_output
    assert_match "packaged_daemon_path=#{opt_libexec/"lazyspotify-librespot"}", version_output
    assert_predicate libexec/"lazyspotify-librespot", :exist?
  end
end
