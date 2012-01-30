# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'magic_enum/version'

Gem::Specification.new do |s|
  s.name          = 'magic_enum'
  s.version       = MagicEnum::Version::STRING
  s.platform      = Gem::Platform::RUBY

  s.authors       = [ 'Dmytro Shteflyuk', 'Oleksiy Kovyrin' ]
  s.email         = 'alexey@kovyrin.net'
  s.homepage      = 'https://github.com/kovyrin/magic-enum'
  s.summary       = 'ActiveRecord plugin that makes it easier to maintain ENUM-like attributes in your models'
  s.description   = 'MagicEnum is a simple ActiveRecord plugin that makes it easier to maintain ENUM-like attributes in your models.'

  s.rdoc_options = [ '--charset=UTF-8' ]

  s.files            = `git ls-files`.split("\n")
  s.require_paths    = [ 'lib' ]
  s.extra_rdoc_files = [ 'LICENSE', 'README.rdoc' ]

  # Dependencies
  s.add_dependency 'activerecord', '< 3.3'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'yard'
end
