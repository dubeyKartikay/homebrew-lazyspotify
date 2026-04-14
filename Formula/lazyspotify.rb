class Lazyspotify < Formula
  desc "Terminal Spotify client bundled with a patched go-librespot daemon"
  homepage "https://github.com/dubeyKartikay/lazyspotify"
  url "https://github.com/dubeyKartikay/lazyspotify/releases/download/v0.2.1/lazyspotify-v0.2.1-src.tar.gz"
  sha256 "e4fad7d0070ac837d00867d28a2459830a0dbf76d613c3f110eca1aa6fb9c3bf"
  license all_of: ["MIT", "GPL-3.0-only"]

  depends_on "flac" => :build
  depends_on "go" => :build
  depends_on "libogg" => :build
  depends_on "libvorbis" => :build
  depends_on "pkgconf" => :build

  def install
    daemon_path = opt_libexec/"lazyspotify-librespot"
    main_ldflags = [
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Version=0.2.1",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Commit=6065ecb095853ae11ed304dc4473b2ab872011e3",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.BuildDate=2026-04-14T17:15:56Z",
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
    assert_match "version=0.2.1", version_output
    assert_match "packaged_daemon_path=#{opt_libexec/"lazyspotify-librespot"}", version_output
    assert_predicate libexec/"lazyspotify-librespot", :exist?
  end
end
