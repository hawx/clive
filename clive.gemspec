# -*- encoding: utf-8 -*-
require File.expand_path("../lib/clive/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "clive"
  s.version      = Clive::VERSION
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = "Imagine if optparse and gli had a son called clive."
  s.homepage     = "http://github.com/hawx/clive"
  s.email        = "m@hawx.me"
  s.author       = "Joshua Hawxwell"
  s.has_rdoc     = false
  
  s.files        = %w(README.md Rakefile LICENSE)
  s.files       += Dir["{bin,lib,man,spec}/**/*"] & `git ls-files -z`.split(" ")
  s.test_files   = Dir["spec/**/*"]
  
  s.executables  = ["clive"]
  s.require_path = 'lib'
  
  s.description  = <<-EOD
    Clive is a DSL for creating a command line interface. It is for people 
    who, like me, love OptionParser's syntax and love GLI's commands.
  EOD
  
end
  
