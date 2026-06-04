class GitHubPrivateGitDownloadStrategy < GitDownloadStrategy
  def initialize(url, name, version, **meta)
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"]
    @github_token = github_cli_token if @github_token.to_s.empty?
    if @github_token.to_s.empty?
      raise "Private Sprout installs require GitHub auth. Run gh auth login, or set HOMEBREW_GITHUB_API_TOKEN."
    end

    authenticated_url = url.sub("https://github.com/", "https://x-access-token:#{@github_token}@github.com/")
    super(authenticated_url, name, version, **meta)
  end

  private

  def github_cli_token
    token = Utils.safe_popen_read("gh", "auth", "token").strip
    token.empty? ? nil : token
  rescue
    nil
  end
end

class Sprout < Formula
  desc "Repository-local task tracker for agents"
  homepage "https://github.com/StreamlinedStartup/sprout"
  url "https://github.com/StreamlinedStartup/sprout.git",
    tag: "v1.2.16",
    using: GitHubPrivateGitDownloadStrategy
  version "1.2.16"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
