# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "omnibus-ctl/version"

Gem::Specification.new do |s|
  s.name        = "omnibus-ctl"
  s.version     = Omnibus::Ctl::VERSION
  s.authors     = ["Opscode, Inc."]
  s.email       = ["legal@chef.io"]
  s.homepage    = "http://github.com/chef/omnibus-ctl"
  s.summary     = %q{Provides command line control for omnibus packages}
  s.description = %q{Provides command line control for omnibus pakcages, rarely used as a gem}

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "rspec_junit_formatter"

  s.bindir       = "bin"
  s.executables  = 'omnibus-ctl'
  s.require_path = 'lib'
  s.files = %w(README.md) + Dir.glob("lib/**/*")
end
