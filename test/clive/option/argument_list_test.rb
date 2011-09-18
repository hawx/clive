$: << File.dirname(__FILE__) + '/../..'
require 'helper'

class ArgumentListTest < MiniTest::Unit::TestCase
  
  def do_zip(list, other)
    list.zip(other).map {|i| i[1] }
  end
  
  def test_zips_found_argument_properly
    a = Clive::Argument.new :a, :type => Integer, :constraint => :even?, :optional => true
    b = Clive::Argument.new :b, :type => Integer, :constraint => :odd?
    c = Clive::Argument.new :c, :type => Integer, :constraint => :even?
    d = Clive::Argument.new :d, :type => Integer, :constraint => :odd?, :optional => true
    
    list = Clive::ArgumentList.new([a, b, c, d])
    
    # These behaviours are definitely what should happen
    assert_equal [nil, '1', '4', nil], do_zip(list, %w(1 4))
    assert_equal [nil, '1', '4', '3'], do_zip(list, %w(1 4 3)) 
    assert_equal ['2', '1', '4', '3'], do_zip(list, %w(2 1 4 3))
    assert_equal ['2', '1', '4', nil], do_zip(list, %w(2 1 4))
    
    # These behaviours may change
    assert_equal [nil, nil, '2', nil], do_zip(list, %w(2))
    assert_equal [nil, '1', nil, nil], do_zip(list, %w(1))
    assert_equal [nil, nil, '2', nil], do_zip(list, %w(2 1))
  end
  
  def test_returns_nice_string
    list = Clive::ArgumentList.new( [
      Clive::Argument.new(:a), 
      Clive::Argument.new(:b, :optional => true),
      Clive::Argument.new(:c, :optional => true),
      Clive::Argument.new(:d)
    ])
    
    assert_equal "<a> [<b> <c>] <d>", list.to_s
  end
  
end