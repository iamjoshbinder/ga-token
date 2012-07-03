# -*- encoding: utf-8 -*-
require File.expand_path('../lib/ga-token/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Robert"]
  gem.email         = ["robert@generalassemb.ly"]
  gem.description   = %q{An interface to the GA(General Assembly) authorization service.}
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/generalassembly/ga-token"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "ga-token"
  gem.require_paths = ["lib"]
  gem.version       = GA::Token::VERSION
end
