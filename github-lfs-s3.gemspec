# frozen_string_literal: true
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'github-lfs-s3/version'

Gem::Specification.new do |gem|
  gem.name          = 'github-lfs-s3'
  gem.version       = GithubLfsS3::VERSION
  gem.authors       = ['Will Jordan']
  gem.email         = ['will@code.org']
  gem.description   = 'Git LFS server for GitHub backed by S3'
  gem.summary       = 'Git LFS server for GitHub backed by S3'
  gem.homepage      = 'https://github.com/wjordan/github-lfs-s3'
  gem.license       = 'Apache 2.0'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'aws-sdk-s3'
  gem.add_dependency 'octokit'
  gem.add_dependency 'sinatra', '~> 2'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rubocop'
end
