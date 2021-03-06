# -*- encoding: utf-8 -*-
require File.expand_path("../lib/clive/version", __FILE__)

Gem::Specification.new do |s|
  s.name         = "clive"
  s.version      = Clive::VERSION
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = "A DSL for building command line interfaces."
  s.homepage     = "http://github.com/hawx/clive"
  s.email        = "m@hawx.me"
  s.author       = "Joshua Hawxwell"
  
  s.files        = %w(README.md LICENSE)
  s.files       += Dir["{bin,lib,man,spec}/**/*"] & `git ls-files -z`.split(" ")
  s.test_files   = Dir["spec/**/*"]

  s.add_development_dependency 'minitest', '~> 2.6'
  s.add_development_dependency 'mocha', '~> 0.10'
  
  s.description  = <<-EOD
    Clive provides a DSL for building command line interfaces. It allows 
    you to define commands and options, which can also take arguments, 
    and then runs the correct stuff!
  EOD
  
end
