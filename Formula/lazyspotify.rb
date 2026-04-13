class Lazyspotify < Formula
  desc "Terminal Spotify client bundled with a patched go-librespot daemon"
  homepage "https://github.com/dubeyKartikay/lazyspotify"
  url "https://github.com/dubeyKartikay/lazyspotify/releases/download/v0.2.0/lazyspotify-v0.2.0-src.tar.gz"
  sha256 "15d33ac6e290efd4ef81499f56a61d1733f3663886d898e5cca6cf84ea54c63c"
  license all_of: ["MIT", "GPL-3.0-only"]

  depends_on "flac" => :build
  depends_on "go" => :build
  depends_on "libogg" => :build
  depends_on "libvorbis" => :build
  depends_on "pkgconf" => :build

  def install
    daemon_path = opt_libexec/"lazyspotify-librespot"
    main_ldflags = [
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Version=0.2.0",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Commit=98bcaab77298480d2d584317014050b5a3778a85",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.BuildDate=2026-04-13T20:32:05Z",
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
    assert_match "version=0.2.0", version_output
    assert_match "packaged_daemon_path=#{opt_libexec/"lazyspotify-librespot"}", version_output
    assert_predicate libexec/"lazyspotify-librespot", :exist?
  end
end
