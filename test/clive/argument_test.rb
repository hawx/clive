$: << File.dirname(__FILE__) + '/..'
require 'helper'

class TestArgument < MiniTest::Unit::TestCase

  def test_name_is_symbol
    a = Clive::Argument.new(:a)
    assert_equal Symbol, a.name.class
    b = Clive::Argument.new('b')
    assert_equal Symbol, b.name.class
  end

  def test_can_be_optional
    a = Clive::Argument.new(:a, :optional => true)
    assert a.optional?
    b = Clive::Argument.new(:b)
    refute b.optional?
  end

  def test_possible_on_type
    a = Clive::Argument.new(:a, :type => Time)
    assert a.possible?('12:34')
    refute a.possible?('not-a-time')
  end

  def test_possible_on_match
    a = Clive::Argument.new(:a, :match => /^[a-e]+![f-o]+\?\.$/)
    assert a.possible?('abe!off?.')
    refute a.possible?('off?abe!.')
  end

  def test_possible_on_within
    a = Clive::Argument.new(:a, :within => %w(dog cat fish))
    assert a.possible?('dog')
    refute a.possible?('mouse')
  end

  def test_possible_with_range
    a = Clive::Argument.new(:a, :type => Integer, :within => 1..11)
    assert a.possible?('8')
    refute a.possible?('100')
  end
  
  def test_possible_with_constraint
    a = Clive::Argument.new(:a, :type => Integer, :constraint => proc {|i| i.odd? })
    assert a.possible?('1')
    refute a.possible?('2')
  end

  def test_coerce
    m = MiniTest::Mock.new
    m.expect(:typecast, 5, ["str"])

    a = Clive::Argument.new(:a)
    a.instance_variable_set(:@type, m)
    assert_equal 5, a.coerce("str")

    m.verify
  end

  def test_create_string
    a = Clive::Argument.new(:a, :optional => false)
    assert_equal "<a>", a.to_s
    b = Clive::Argument.new(:b, :optional => true)
    assert_equal "[<b>]", b.to_s
  end

end
