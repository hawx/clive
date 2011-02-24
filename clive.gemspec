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
  s.has_rdoc     = false
  
  s.files        = %w(README.md LICENSE)
  s.files       += Dir["{bin,lib,man,spec}/**/*"] & `git ls-files -z`.split(" ")
  s.test_files   = Dir["spec/**/*"]
  
  s.require_path = 'lib'
  s.add_dependency 'ast_ast', '~> 0.2.1'
  s.add_dependency 'attr_plus', '~> 0.2.2'
  
  s.description  = <<-EOD
    Clive provides a DSL for building command line interfaces. It allows 
    you to define commands, switches, flags (switches with options) and 
    boolean switches, it then parses the input and runs the correct blocks.
  EOD
  
end
  
