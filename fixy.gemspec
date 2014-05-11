require 'fixy/version'

Gem::Specification.new do |spec|
  spec.name          = 'fixy'
  spec.version       = Fixy::VERSION
  spec.authors       = ['Omar Skalli']
  spec.email         = ['omar@zenpayroll.com']
  spec.description   = %q{Library for generating fixed width flat files.}
  spec.summary       = %q{Provides a DSL for defining, generating, and debugging fixed width documents.}
  spec.homepage      = 'https://github.com/chetane/fixy'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rspec'

  spec.add_runtime_dependency 'rake'
  spec.add_runtime_dependency 'active_support'
end