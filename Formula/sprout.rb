require "download_strategy"

class GitHubPrivateTarballDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    return if @github_token

    raise CurlDownloadStrategyError, "HOMEBREW_GITHUB_API_TOKEN is required to install sprout from the private source repository."
  end

  private

  def _fetch(url:, resolved_url:)
    curl_download url,
      "--header", "Authorization: Bearer #{@github_token}",
      "--header", "Accept: application/vnd.github+json",
      to: temporary_path
  end
end

class Sprout < Formula
  desc "Repository-local task tracker for agents"
  homepage "https://github.com/StreamlinedStartup/sprout"
  url "https://api.github.com/repos/StreamlinedStartup/sprout/tarball/v1.2.8", using: GitHubPrivateTarballDownloadStrategy
  sha256 "0d2e3c972938ef81584c1d5a9007656013a72d99e9eb87edddb2109d4b3aef09"
  version "1.2.8"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
