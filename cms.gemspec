# frozen_string_literal: true

require_relative "lib/cms/version"

Gem::Specification.new do |spec|
  spec.name        = "cms42"
  spec.version     = Cms::VERSION
  spec.authors     = ["shift42"]
  spec.email       = ["hello@shift42.io"]
  spec.summary     = "Modular, mountable CMS engine for Rails apps"
  spec.description = "A mountable Rails CMS engine. Multi-site, multilingual, content blocks, " \
                     "page tree, media management, forms, headless JSON API, and webhooks."
  spec.homepage    = "https://github.com/shift42/cms"
  spec.license     = "MIT"
  spec.required_ruby_version = ">= 3.2"
  spec.require_paths = ["lib"]

  spec.files = Dir.chdir(__dir__) do
    Dir["{app,bin,config,db,lib}/**/*", "MIT-LICENSE", "README.md", "Rakefile", "cms.gemspec"]
  end

  spec.add_dependency "actiontext", ">= 7.1", "< 9.0"
  spec.add_dependency "discard", "~> 1.4"
  spec.add_dependency "importmap-rails", ">= 1.2"
  spec.add_dependency "rails", ">= 7.1", "< 9.0"
  spec.add_dependency "stimulus-rails", ">= 1.3"
  spec.add_dependency "turbo-rails", ">= 1.5"
  spec.metadata["rubygems_mfa_required"] = "true"
end
