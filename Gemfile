source "https://rubygems.org"

# Specify your gem's dependencies in external_fields.gemspec
gemspec

if ENV["TRAVIS"] == "true" && ENV["ACTIVERECORD_VERSION"]
  gem "activerecord", ENV["ACTIVERECORD_VERSION"]
end
