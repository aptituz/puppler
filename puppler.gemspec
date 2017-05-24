# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'puppler/version'

Gem::Specification.new do |spec|
  spec.name          = 'puppler'
  spec.version       = Puppler::VERSION
  spec.authors       = ['Patrick Schoenfeld']
  spec.email         = ['patrick.schoenfeld@credativ.de']

  spec.summary       = 'tool to create git-bundles from puppet modules'
  spec.description   = 'puppler evaluates a Puppetfile and creates git-bundles from it'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'none'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'subprocess'
  spec.add_runtime_dependency 'thor'
  spec.add_runtime_dependency 'rainbow'
  spec.add_runtime_dependency 'r10k'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'gem-release'
  spec.add_development_dependency 'aruba'
  spec.add_development_dependency 'pry-byebug'
end
