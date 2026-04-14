class Lazyspotify < Formula
  desc "Terminal Spotify client bundled with a patched go-librespot daemon"
  homepage "https://github.com/dubeyKartikay/lazyspotify"
  url "https://github.com/dubeyKartikay/lazyspotify/releases/download/v0.2.1/lazyspotify-v0.2.1-src.tar.gz"
  sha256 "d6472ee9f43aeacc9f327921b54e4669c83bcdebca511cccbd4f6cc15a9686ff"
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
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.Commit=a69fd76c65c979c6bb48572e87d1b2dc72387f97",
      "-X", "github.com/dubeyKartikay/lazyspotify/buildinfo.BuildDate=2026-04-14T18:12:38Z",
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
