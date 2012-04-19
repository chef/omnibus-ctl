# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omnibus-ctl/version"

Gem::Specification.new do |s|
  s.name        = "omnibus-ctl"
  s.version     = Omnibus::Ctl::VERSION
  s.authors     = ["Opscode, Inc."]
  s.email       = ["legal@opscode.com"]
  s.homepage    = "http://github.com/opscode/omnibus-ctl"
  s.summary     = %q{Provides command line control for omnibus packages}
  s.description = %q{Provides command line control for omnibus pakcages, rarely used as a gem}

  s.rubyforge_project = "omnibus-ctl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
