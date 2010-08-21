# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{clive}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Joshua Hawxwell"]
  s.date = %q{2010-08-21}
  s.description = %q{Clive is a DSL for creating a command line interface. It is for people who, like me, love OptionParser's syntax and love GLI's commands.}
  s.email = %q{m@hawx.me}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.md",
     "Rakefile",
     "VERSION",
     "clive.gemspec",
     "lib/clive.rb",
     "lib/clive/bool.rb",
     "lib/clive/command.rb",
     "lib/clive/exceptions.rb",
     "lib/clive/ext.rb",
     "lib/clive/flag.rb",
     "lib/clive/option.rb",
     "lib/clive/switch.rb",
     "lib/clive/tokens.rb",
     "test/bin_test",
     "test/helper.rb",
     "test/test_boolean.rb",
     "test/test_clive.rb",
     "test/test_command.rb",
     "test/test_exceptions.rb",
     "test/test_flag.rb",
     "test/test_switch.rb",
     "test/test_token.rb"
  ]
  s.homepage = %q{http://github.com/hawx/clive}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Imagine if optparse and gli had a son called clive.}
  s.test_files = [
    "test/helper.rb",
     "test/test_boolean.rb",
     "test/test_clive.rb",
     "test/test_command.rb",
     "test/test_exceptions.rb",
     "test/test_flag.rb",
     "test/test_switch.rb",
     "test/test_token.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

