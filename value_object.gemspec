$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'value_object/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'value_object'
  s.version     = ValueObject::VERSION
  s.authors     = ['Emeric']
  s.email       = ['egaichet@snapp.fr']
  s.homepage    = 'https://github.com/Snapp-FidMe/rails-value-object'
  s.summary     = 'Value object management for rails active records'
  s.description = 'Override getters and setters to use custom value object to dry active record from too much logic'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5'

  s.add_development_dependency 'sqlite3'
end
