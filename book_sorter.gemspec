# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'book_sorter/version'

Gem::Specification.new do |spec|
  spec.name          = 'book_sorter'
  spec.version       = BookSorter::VERSION
  spec.authors       = ['Justin Harrison']
  spec.email         = ['justin@matthin.com']

  spec.summary       = 'Sorts ebooks into dewey decimal categories.'
  spec.homepage      = 'https://github.com/matthin/book_sorter'
  spec.license       = 'MIT'

  spec.files         = Dir.glob('lib/**/*')
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'httparty', '~> 0.13'
  spec.add_development_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
