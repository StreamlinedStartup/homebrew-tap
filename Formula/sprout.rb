require "download_strategy"

class GitHubPrivateTarballDownloadStrategy < AbstractFileDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    @github_token = github_cli_token
    @github_token = ENV["HOMEBREW_GITHUB_API_TOKEN"] if @github_token.to_s.empty?
    if @github_token.to_s.empty?
      raise "Private Sprout installs require GitHub auth. Run gh auth login, or set HOMEBREW_GITHUB_API_TOKEN."
    end
  end

  def fetch(timeout: nil)
    download_lock = DownloadLock.new(temporary_path)
    begin
      download_lock.lock
      if cached_location.exist?
        puts "Already downloaded: #{cached_location}"
      else
        ohai "Downloading #{url} with gh api"
        temporary_path.dirname.mkpath
        api_path = url.sub("https://api.github.com", "")
        archive = Utils.safe_popen_read({ "GH_TOKEN" => @github_token }, gh_executable, "api", api_path)
        IO.binwrite(temporary_path, archive)
        temporary_path.rename(cached_location.to_s)
      end
      create_symlink_to_cached_download(cached_location)
    ensure
      download_lock.unlock(unlink: true)
    end
  end

  private

  def gh_executable
    gh = HOMEBREW_PREFIX/"bin/gh"
    return gh.to_s if gh.executable?

    "gh"
  end

  def github_cli_token
    token = Utils.safe_popen_read(gh_executable, "auth", "token").strip
    token.empty? ? nil : token
  rescue
    nil
  end
end

class Sprout < Formula
  desc "Repository-local task tracker for agents"
  homepage "https://github.com/StreamlinedStartup/sprout"
  url "https://api.github.com/repos/StreamlinedStartup/sprout/tarball/v1.2.19",
    using: GitHubPrivateTarballDownloadStrategy
  sha256 "6e49af7fe715ebf2c97164f4e7f5ef102e78af2177ed30963a62de3c5a1bd2da"
  version "1.2.19"

  depends_on "go" => :build

  def install
    system "go", "build", "-trimpath", "-ldflags", "-X main.version=#{version}", "-o", bin/"sprout", "."
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/sprout version")
  end
end
