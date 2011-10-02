$: << File.dirname(__FILE__) + '/../..'
require 'helper'

class Clive::Argument
  def to_h
    {
      :name       => @name,
      :optional   => @optional,
      :type       => @type,
      :match      => @match,
      :within     => @within,
      :default    => @default,
      :constraint => @constraint
    }
  end
end

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
    
    s = subject.new(Clive::Option::OPT_KEYS, Clive::Option::ARG_KEYS, opts)
    
    a = [Clive::Argument::DEFAULTS.merge({:name => :a, :within => 1..5})]
    b = s.args.map {|i| i.to_h }
    assert_equal a, b
    
    assert_equal({:head => true}, s.opts)
  end

end
