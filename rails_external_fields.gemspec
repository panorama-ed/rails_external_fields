# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails_extrenal_fields/version"

Gem::Specification.new do |spec|
  spec.name          = "rails_external_fields"
  spec.version       = RailsExternalFields::VERSION
  spec.authors       = ["Sagar Jauhari"]
  spec.email         = ["sagarjauhari@gmail.com"]
  spec.summary       = "Access attributes from an associated model."
  spec.description   = "This concern maintains the illusion that a given object"\
                       "has specified attributes, when those attributes are in"\
                       "fact attached to an associated object. This is"\
                       "particularly useful for different classes within a"\
                       "single-table inheritance table to have access to"\
                       "separate fields in class-specific associations."

  spec.homepage      = "https://github.com/panorama-ed/rails-external-fields"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4"
  spec.add_development_dependency "overcommit", "~> 0.23"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "rspec-rails", "~> 3.2"
  spec.add_development_dependency "rubocop", "~> 0.29"
  spec.add_development_dependency "temping", "~> 3.2"
  spec.add_development_dependency "sqlite3"
end
