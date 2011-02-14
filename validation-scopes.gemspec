# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "validation-scopes"
  s.version     = "0.0.3"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Steve Hodgkiss"]
  s.email       = ["steve@hodgkiss.me.uk"]
  s.homepage    = "https://github.com/stevehodgkiss/validation-scopes"
  s.summary     = %q{Scope ActiveModel validations}
  s.description = %q{Scope ActiveModel validations}

  s.rubyforge_project = "validation-scopes"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_dependency("activemodel")
end
