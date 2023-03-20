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

  spec.add_development_dependency 'bundler', '>= 2.2.33'
  spec.add_development_dependency 'rake', '>= 12.3.3'
  spec.add_development_dependency 'rspec-rails'

  # By not including Rails as a dependency, we can use the gem with different
  # versions of Rails (a sure recipe for disaster, I'm sure), which is needed
  # until we bump Dradis Pro to 4.1.
  # s.add_dependency 'rails', '~> 4.1.1'
end
