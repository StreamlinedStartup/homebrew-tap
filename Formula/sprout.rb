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
  url "https://api.github.com/repos/StreamlinedStartup/sprout/tarball/v1.2.9", using: GitHubPrivateTarballDownloadStrategy
  sha256 "d59d939783dd4f565ff4ed8741464d3336d79009a568c1f5a9ea9619293dc8f5"
  version "1.2.9"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
