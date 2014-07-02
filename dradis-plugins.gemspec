$:.push File.expand_path('../lib', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name = 'dradis-plugins'
  s.version = '3.0.0'
  s.summary = 'Plugin manager for the Dradis Framework project.'
  s.description = 'Required dependency for Dradis Framework.'

  s.license = 'GPL-2'

  s.authors = ['Daniel Martin']
  s.email = ['etd@nomejortu.com']
  s.homepage = 'http://dradisframework.org'

  s.files = `git ls-files`.split($\)
  s.executables = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # By not including Rails as a dependency, we can use the gem with different
  # versions of Rails (a sure recipe for disaster, I'm sure), which is needed
  # until we bump Dradis Pro to 4.1.
  # s.add_dependency 'rails', '~> 4.1.1'
end
