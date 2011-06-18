$: << File.dirname(__FILE__)

if RUBY_VERSION >= "1.9"
  require 'duvet'
  Duvet.start :filter => 'lib/duvet'
end

require_relative '../lib/clive'

require 'minitest/mock'
require 'minitest/pride'

MiniTest::Unit.autorun

