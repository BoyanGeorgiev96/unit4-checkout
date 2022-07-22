# frozen_string_literal: true

require_relative "lib/unit4/checkout/version"

Gem::Specification.new do |spec|
  spec.name = "unit4-checkout"
  spec.version = Unit4::Checkout::VERSION
  spec.authors = ["Boyan Georgiev"]
  spec.email = ["bbgeorgiev96@gmail.com"]

  spec.summary = "Checkout gem for Unit4 technical task"
  spec.description = "A Ruby gem that helps the user implement a checkout system by supplying only the promotional rules"
  spec.homepage = "https://github.com/BoyanGeorgiev96/unit4-checkout"
  spec.licenses = ["MIT"]
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org/"
  

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/BoyanGeorgiev96/unit4-checkout"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
