# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development do
  gem "codecov"
  gem "panolint-ruby", github: "panorama-ed/panolint-ruby", branch: "main"
  gem "rspec"
  gem "rspec-rails"
  gem "sqlite3"
  gem "temping"
end
