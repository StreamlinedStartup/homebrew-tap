require "download_strategy"

class GitHubPrivateTarballDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    @github_token = github_cli_token if @github_token.to_s.empty?
    return unless @github_token.to_s.empty?

    raise CurlDownloadStrategyError, "Private Sprout installs require GitHub auth. Run gh auth login, or set HOMEBREW_GITHUB_API_TOKEN."
  end

  private

  def github_cli_token
    token = Utils.safe_popen_read("gh", "auth", "token").strip
    token.empty? ? nil : token
  rescue
    nil
  end

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
  url "https://api.github.com/repos/StreamlinedStartup/sprout/tarball/v1.2.14", using: GitHubPrivateTarballDownloadStrategy
  sha256 "39863cfc6e618ceb26dca06d0d3be9db992dbf25532adb45fe5d1db2861709c9"
  version "1.2.14"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
