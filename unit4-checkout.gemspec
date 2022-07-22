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

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", "~> 7.0.3"
  spec.add_dependency "erb", "~> 2.2.3"
end
