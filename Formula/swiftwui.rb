class Swiftwui < Formula
  desc "CLI for SwiftWUI - SwiftUI-inspired web framework compiled to WebAssembly"
  homepage "https://github.com/kazi05/swiftwui"
  url "https://github.com/kazi05/swiftwui/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "58b50770bc505bf66a69b06230ec7502d83cfe8d03c39b6361d8dd4b42b845b9"
  license "MIT"
  head "https://github.com/kazi05/swiftwui.git", branch: "main"

  depends_on xcode: ["26.0", :build]   # needs Swift >= 6.2
  depends_on macos: :sonoma            # Package.swift: .macOS(.v14)

  def install
    # --disable-sandbox: SwiftPM's own sandbox cannot nest inside Homebrew's
    # build sandbox (sandbox_apply fails); brew's outer sandbox still applies.
    system "swift", "build", "--disable-sandbox", "-c", "release", "--product", "swiftwui"
    libexec.install ".build/release/swiftwui",
                    ".build/release/SwiftWUI_SwiftWUIToolchain.bundle"
    # Exec script, not a symlink: the CLI locates its resource bundle via
    # Bundle.module next to the real executable.
    bin.write_exec_script libexec/"swiftwui"
  end

  def caveats
    <<~EOS
      Building SwiftWUI apps additionally requires the Swift 6.3.3 toolchain
      and the matching WASM SDK (versions must match exactly):
        swiftly install 6.3.3 && swiftly use 6.3.3
        swift sdk install <swift-6.3.3-RELEASE_wasm bundle URL from swift.org/download>
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/swiftwui --version")
    system bin/"swiftwui", "init", "Smoke"
    assert_match "github.com/kazi05/swiftwui", (testpath/"Smoke/Package.swift").read
  end
end
