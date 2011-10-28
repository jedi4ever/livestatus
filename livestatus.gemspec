# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "livestatus/version"

Gem::Specification.new do |s|
  s.name        = "livestatus"
  s.version     = Livestatus::VERSION
  s.authors     = ["Benedikt Böhm"]
  s.email       = ["bb@xnull.de"]
  s.homepage    = ""
  s.summary     = %q{Simple API wrapper for MK Livestatus and LivestatusSlave}
  s.description = %q{Simple API wrapper for MK Livestatus and LivestatusSlave}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "patron"
  s.add_runtime_dependency "yajl-ruby"
end
