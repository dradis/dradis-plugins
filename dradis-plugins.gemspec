$:.push File.expand_path('../lib', __FILE__)

require 'dradis/plugins/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.platform      = Gem::Platform::RUBY
  spec.name = 'dradis-plugins'
  spec.version = Dradis::Plugins::VERSION::STRING
  spec.summary = 'Plugin manager for the Dradis Framework project.'
  spec.description = 'Required dependency for Dradis Framework.'

  spec.license = 'GPL-2'

  spec.authors = ['Daniel Martin']
  spec.email = ['etd@nomejortu.com']
  spec.homepage = 'http://dradisframework.org'

  spec.files = `git ls-files`.split($\)
  spec.executables = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec-rails'
end
