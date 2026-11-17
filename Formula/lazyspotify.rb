class Lazyspotify < Formula
  desc "Terminal Spotify client bundled with a patched go-librespot daemon"
  homepage "https://github.com/dubeyKartikay/lazyspotify"
  url "https://github.com/dubeyKartikay/lazyspotify/releases/download/v0.6.1/lazyspotify-v0.6.1-src.tar.gz"
  sha256 "a8a2e8fe426218ccc29b04a38cc6f7ef8324ce4dc215c143655815ecd28871a5"
  license all_of: ["MIT", "GPL-3.0-only"]

  depends_on "flac"
  depends_on "go" => :build
  depends_on "libogg"
  depends_on "libvorbis"
  depends_on "mpg123"
  depends_on "pkgconf" => :build

  on_linux do
    depends_on "alsa-lib"
  end

  def install
    daemon_path = opt_libexec/"lazyspotify-librespot"
    main_ldflags = [
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Version=0.6.1",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Commit=6dd042c2924c97c8f2191d902450cc86441136b2",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.BuildDate=2026-11-17T17:33:14Z",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.PackagedDaemonPath=#{daemon_path}",
    ]

    system "go", "build", "-trimpath", "-buildvcs=false",
      "-ldflags", main_ldflags.join(" "),
      "-o", bin/"lazyspotify",
      "./cmd/lazyspotify"

    cd buildpath/"third_party/go-librespot" do
      system "go", "build", "-trimpath", "-buildvcs=false",
        "-ldflags", "-X github.com/devgianlu/go-librespot.version=v0.8.0",
        "-o", libexec/"lazyspotify-librespot",
        "./cmd/daemon"
    end
  end

  test do
    version_output = shell_output("#{bin}/lazyspotify version")
    assert_match "version=0.6.1", version_output
    assert_match "packaged_daemon_path=#{opt_libexec/"lazyspotify-librespot"}", version_output
    assert_predicate libexec/"lazyspotify-librespot", :exist?
  end
end
