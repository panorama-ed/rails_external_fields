lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "external_fields/version"

Gem::Specification.new do |spec| # rubocop:disable Metrics/BlockLength
  spec.name          = "external_fields"
  spec.version       = ExternalFields::VERSION
  spec.authors       = ["Sagar Jauhari"]
  spec.email         = ["sagarjauhari@gmail.com"]
  spec.summary       = "Access attributes from an associated model."
  spec.description   = "This concern maintains the illusion that a given "\
                       "object has specified attributes, when those "\
                       "attributes are in fact attached to an associated "\
                       "object. This is particularly useful for different "\
                       "classes within a single-table inheritance table to "\
                       "have access to separate fields in class-specific "\
                       "associations."

  spec.homepage      = "https://github.com/panorama-ed/rails_external_fields"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_dependency "activesupport", ">= 4.0"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "codecov"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3", "~> 1.4.0"
  spec.add_development_dependency "temping"
end
