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

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "~> 3.2"
  s.add_development_dependency "rspec_junit_formatter"

  s.bindir       = "bin"
  s.executables  = 'omnibus-ctl'
  s.require_path = 'lib'
  s.files = %w(LICENSE) + Dir.glob("lib/**/*")
end
