class Lazyspotify < Formula
  desc "Terminal Spotify client bundled with a patched go-librespot daemon"
  homepage "https://github.com/dubeyKartikay/lazyspotify"
  url "https://github.com/dubeyKartikay/lazyspotify/releases/download/v0.5.2/lazyspotify-v0.5.2-src.tar.gz"
  sha256 "99b721fc70ce4bd595b28b895f7e346304430ee7a2614e236f6a2eed7edb32bb"
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
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Version=0.5.2",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Commit=5a4bbb8632988681a069516f5335a34acb48bcc7",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.BuildDate=2026-10-15T18:49:03Z",
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
    assert_match "version=0.5.2", version_output
    assert_match "packaged_daemon_path=#{opt_libexec/"lazyspotify-librespot"}", version_output
    assert_predicate libexec/"lazyspotify-librespot", :exist?
  end
end
