$: << File.dirname(__FILE__)

if RUBY_VERSION >= "1.9"
  require 'duvet'
  Duvet.start :filter => 'lib/duvet'
end

require_relative '../lib/clive'

begin
  gem 'minitest'
rescue
end

require 'minitest/mock'
require 'minitest/pride'
require 'minitest/autorun'

