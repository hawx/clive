$: << File.dirname(__FILE__) + '/../..'
require 'helper'

class ArgumentParserTest < MiniTest::Unit::TestCase

  def subject
    Clive::Option::ArgumentParser
  end

  def test_separates_options_from_arguments
    opts = {
      :args => '<a>',
      :head => true,
      :in   => 1..5
    }
    
    s = subject.new(opts)
    
    a = [Clive::Argument::DEFAULTS.merge({:name => :a, :within => 1..5})]
    b = s.args.map {|i| i.to_h }
    assert_equal a, b
    
    assert_equal({:head => true}, s.opts)
  end

end
