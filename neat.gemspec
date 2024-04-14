# frozen_string_literal: true

require_relative 'lib/neat/version'

Gem::Specification.new do |spec|
  spec.name = 'neat'
  spec.version = Neat::VERSION
  spec.authors = ['TiuTalk']
  spec.email = ['github@thiagobelem.net']

  spec.summary = 'NEAT (NeuroEvolution of Augmenting Topologies) implementation in Ruby'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/TiuTalk/neat'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
