require 'duvet'
Duvet.start :filter => 'clive/lib'

require 'test/unit'
require 'shoulda'
require 'rr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require File.join(File.dirname(__FILE__), '..', 'lib', 'clive')

class Test::Unit::TestCase
  include RR::Adapters::TestUnit
end
