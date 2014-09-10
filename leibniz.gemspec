# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'leibniz/version'

Gem::Specification.new do |spec|
  spec.name          = "leibniz"
  spec.version       = Leibniz::VERSION
  spec.authors       = ["Stephen Nelson-Smith"]
  spec.email         = ["stephen@atalanta-systems.com"]
  spec.description   = %q{Automated Infrastructure Acceptance Tests}
  spec.summary       = %q{Arguably Leibniz independently invented integration.}
  spec.homepage      = "http://leibniz.cc"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "test-kitchen", "~> 1.0"
  spec.add_dependency "kitchen-vagrant"
  spec.add_dependency "thor"
  spec.add_dependency "cucumber"
  spec.add_dependency "chef", "> 11"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'aruba',     '~> 0.5'
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"

end
