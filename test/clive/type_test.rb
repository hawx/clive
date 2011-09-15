$: << File.dirname(__FILE__) + '/..'
require 'helper'

class TypeTest < MiniTest::Unit::TestCase

  def create(&block)
    Class.new(Clive::Type, &block)
  end
  
  def test_can_match_with_shorthand_regexp
    type = create { match /yes|no/ }
    assert type.valid?('yes')
    refute type.valid?('odd')
  end
  
  def test_can_match_with_shorthand_method
    type = create { match :five? }
    String.send(:define_method, :five?) { size == 5 }
    assert type.valid?('12345')
    refute type.valid?('1234')
  end
  
  def test_can_refute_with_shorthand_regexp
    type = create { refute /yes|no/ }
    refute type.valid?('yes')
    assert type.valid?('odd')
  end
  
  def test_can_refute_with_shorthand_method
    type = create { refute :five? }
    String.send(:define_method, :five?) { size == 5 }
    refute type.valid?('12345')
    assert type.valid?('1234')
  end
  
  def test_can_cast_with_shorthand
    type = create { cast :to_img }
    obj = MiniTest::Mock.new
    obj.expect(:send, nil, [:to_img])
    type.typecast(obj)
    obj.verify
  end
  
  def test_calls_instance_valid
    type = create { def valid?(o); puts "Called valid?"; end }

    assert_output "Called valid?\n" do
      type.valid?('arg')
    end
  end
  
  def test_calls_instance_typecast
    type = create { def typecast(o); puts "Called typecast"; end }
  
    assert_output "Called typecast\n" do
      type.typecast('arg')
    end
  end
  
  def test_finds_type_class
    assert_equal Clive::Type::String, Clive::Type.find_class('String')
    assert_equal Clive::Type::Integer, Clive::Type.find_class('Type::Integer')
    assert_nil Clive::Type.find_class('What')
  end

end