# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fencer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Dan Cheail"]
  gem.email         = ["dan@undumb.com"]
  gem.description   = %q{Fixed-length/delimited record parser DSL}
  gem.summary       = %q{Fencer makes working with fixed-length and delimited
                       text-based records simpler by providing a flexible DSL
                       for defining field lengths and transformations}

  gem.homepage      = "https://github.com/undumb/fencer"
  gem.files         = `git ls-files`.split($\) - %w(Gemfile .gitignore)
  # gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fencer"
  gem.require_paths = ["lib"]
  gem.version       = Fencer::VERSION
  
  gem.add_development_dependency "rspec", "~> 2.10"
end
