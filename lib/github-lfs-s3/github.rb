require 'octokit'
require 'digest'

module GithubLfsS3
  # Authenticate write-access to GitHub repo via Octokit.
  # Use cache to reduce API calls if provided.
  class Github
    attr_reader :repo, :cache

    def initialize(repo, cache = nil)
      @repo = repo
      @cache = cache
    end

    def authenticate(username, password)
      cache_key = Digest::SHA2.hexdigest [repo, username, password].join('/')
      return access?(username, password) unless cache
      cache.fetch(cache_key) do
        break unless access?(username, password)
        true
      end
    end

    private

    def access?(username, password)
      client = Octokit::Client.new(login: username, password: password)
      permission = client.permission_level(repo, client.user.login)
      %w[admin write].include?(permission)
    end
  end
end
