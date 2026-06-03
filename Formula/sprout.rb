class Sprout < Formula
  desc "Repository-local task tracker for agents"
  homepage "https://github.com/StreamlinedStartup/sprout"
  url "https://api.github.com/repos/StreamlinedStartup/sprout/tarball/v1.2.7"
  sha256 "f270f71cd1815a6478e09632178a1df46034cb2c9758b9e4a7a7a435a3663dec"
  version "1.2.7"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
