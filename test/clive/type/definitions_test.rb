$: << File.dirname(__FILE__) + '/../..'
require 'helper'

class DefinitionsTest < MiniTest::Unit::TestCase

  def test_object
    s = Clive::Type::Object
    
    assert s.valid?('a')
    assert_kind_of Object, s.typecast('a')
  end
  
  def test_string
    s = Clive::Type::String
    
    refute s.valid?(nil)
    assert_kind_of String, s.typecast('a')
  end
  
  def test_symbol
    s = Clive::Type::Symbol
    
    refute s.valid?(nil)
    
    r = s.typecast('a')
    assert_kind_of Symbol, r
    assert_equal :a, r
  end
  
  def test_integer
    s = Clive::Type::Integer
    
    %w(120 120.5 .5 120e7 120.5e7).each do |a|
      assert s.valid?(a)
      assert s.valid?('-'+a)
    end
    refute s.valid?('abc')
    
    r = s.typecast('120.50e7')
    assert_kind_of Integer, r
    assert_equal 120, r
  end
  
  def test_strict_integer
    s = Clive::Type::StrictInteger
    
    %w(120 120e7).each do |a|
      assert s.valid?(a)
      assert s.valid?('-'+a)
    end
    
    %w(120.5 .5 120.5e7).each do |a|
      refute s.valid?(a)
      refute s.valid?('-'+a)
    end
    
    refute s.valid?('abc')
    
    r = s.typecast('120')
    assert_kind_of Integer, r
    assert_equal 120, r
  end
  
  
  def test_float
    s = Clive::Type::Float
    
    %w(120 120.5 .5 120e7 120.5e7).each do |a|
      assert s.valid?(a)
      assert s.valid?('-'+a)
    end
    refute s.valid?('abc')
    
    r = s.typecast('120.50e7')
    assert_kind_of Float, r
    assert_equal 120.50e7, r
  end
  
  def test_boolean
    s = Clive::Type::Boolean
    
    %w(true t yes y on false f no n off).each do |a|
      assert s.valid?(a)
    end
    refute s.valid?('abc')
    
    assert_equal true, s.typecast('y')
    assert_equal false, s.typecast('off')
  end
  
  def test_pathname
    s = Clive::Type::Pathname
    
    assert s.valid?('~/somewhere')
    refute s.valid?(nil)
    
    r = s.typecast('~/somewhere')
    assert_kind_of Pathname, r
    assert_equal '~/somewhere', r.to_s
  end
  
  def test_range
    s = Clive::Type::Range
    
    %w(1..5 1...5 1-5).each do |a|
      assert s.valid?(a)
    end
    
    r = s.typecast('1-5')
    assert_kind_of Range, r
    assert_equal '1'..'5', r
  end
  
  def test_array
    s = Clive::Type::Array
    
    ['a,b,c', '"hello",123,true,"what a sentence"'].each do |a|
      assert s.valid?(a)
    end
    
    r = s.typecast('"hello",123,true,"what a sentence"')
    assert_kind_of Array, r
    assert_equal ['"hello"', '123', 'true', '"what a sentence"'], r
  end
  
  def test_time
    s = Clive::Type::Time
    
    %w(12:50 12:50:30).each do |a|
      assert s.valid?(a)
    end
    
    assert_kind_of Time, s.typecast('12:50')
  end

end