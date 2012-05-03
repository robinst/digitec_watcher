# -*- encoding: utf-8 -*-
require File.expand_path('../lib/digitec_watcher/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Robin Stocker"]
  gem.email         = ["robin@nibor.org"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "digitec_watcher"
  gem.require_paths = ["lib"]
  gem.version       = DigitecWatcher::VERSION

  gem.add_dependency 'nokogiri', '~> 1.5.2'
  gem.add_dependency 'actionmailer', '~> 3.2.3'
end
