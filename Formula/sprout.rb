require "download_strategy"

class GitHubPrivateTarballDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    return if @github_token

    raise CurlDownloadStrategyError, "HOMEBREW_GITHUB_API_TOKEN is required to install sprout from the private source repository."
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download url,
      "--header", "Authorization: Bearer #{@github_token}",
      "--header", "Accept: application/vnd.github+json",
      to: temporary_path,
      timeout: timeout
  end
end

class Sprout < Formula
  desc "Repository-local task tracker for agents"
  homepage "https://github.com/StreamlinedStartup/sprout"
  url "https://api.github.com/repos/StreamlinedStartup/sprout/tarball/v1.2.12", using: GitHubPrivateTarballDownloadStrategy
  sha256 "d291efdf86d3688ed34c827cead850dbc20ce8db9fd7e04d7d62fd30a8acc861"
  version "1.2.12"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
