# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'polymer/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'polymer-rails'
  spec.version       = Polymer::Rails::VERSION
  spec.authors       = ['Ian MacLeod']
  spec.email         = ['ian@nevir.net']
  spec.summary       = %q{Support for Polymer-enabled web components in Rails}
  spec.license       = 'BSD'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']

  spec.add_dependency 'railties', '~> 4.0'
  spec.add_dependency 'sprockets-htmlimports', '~> 0.0'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
end
