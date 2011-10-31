$: << File.dirname(__FILE__) + '/..'

if RUBY_VERSION >= "1.9"
  require 'fileutils'
  begin
    require 'duvet'
    Duvet.start :filter => 'lib/clive'
  rescue LoadError
    # it doesn't really matter
  end
end

require 'lib/clive'
require 'rubygems'
require 'shellwords'

def s(str)
  Shellwords.split(str)
end

gem 'minitest' # use latest version
require 'minitest/autorun'

require 'extras/red_green'
require 'extras/expectations'
require 'extras/focus'

require 'mocha'
