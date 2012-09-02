# -*- encoding: utf-8 -*-
require File.expand_path('../lib/digitec_watcher/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Robin Stocker"]
  gem.email         = ["robin@nibor.org"]
  gem.summary       = %q{Notify about Digitec price changes per e-mail}
  gem.description   = %q{Script to watch the Digitec website for price changes and send out notifications per e-mail}
  gem.homepage      = "https://github.com/robinst/digitec_watcher"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "digitec_watcher"
  gem.require_paths = ["lib"]
  gem.version       = DigitecWatcher::VERSION

  gem.add_dependency 'nokogiri', '~> 1.5.2'
  gem.add_dependency 'actionmailer', '~> 3.2.3'

  gem.add_development_dependency 'bundler', '~> 1.1'
  gem.add_development_dependency 'shoulda-context', '~> 1.0'
end
