# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omnibus-ctl/version"

Gem::Specification.new do |s|
  s.name        = "omnibus-ctl"
  s.version     = Omnibus::Ctl::VERSION
  s.authors     = ["Chef Software, Inc."]
  s.email       = ["legal@chef.io"]
  s.licenses    = ["Apache-2.0"]
  s.homepage    = "http://github.com/chef/omnibus-ctl"
  s.summary     = %q{Provides command line control for omnibus packages}
  s.description = %q{Provides command line control for omnibus pakcages, rarely used as a gem}

  s.add_dependency "highline"
  s.add_dependency "rest-client"
#  s.add_dependency "pg", "= 0.17.1" # Locked to the version currently in omnibus-software
  s.add_dependency "mixlib-config"
  s.add_dependency "mixlib-cli"
  s.add_dependency "mixlib-log"
  s.add_dependency "levenshtein-ffi", "~> 1.1"
  
  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "bundler", "~> 1.7"
  s.add_development_dependency "chefstyle"
  s.add_development_dependency "guard-rspec" # check if we are still using this
  
  s.bindir       = "bin"
  s.executables  = 'omnibus-ctl'
  s.require_path = 'lib'
  s.files = %w(README.md) + Dir.glob("lib/**/*")
end
