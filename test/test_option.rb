require_relative 'helper'

class TestOption < MiniTest::Unit::TestCase

  def test_head
    h = Clive::Option.new(nil,nil,nil,{:head => true})
    assert h.head?
    refute h.tail?
  end
  
  def test_tail
    t = Clive::Option.new(nil,nil,nil,{:tail => true})
    assert t.tail?
    refute t.head?
  end
  
  def test_parsing_argument_string
    a = Clive::Option.new(nil,nil,nil,{:args => '<h> <w>'})
    b = Clive::Option.new(nil,nil,nil,{:args => '<h> [<w>]'})
    c = Clive::Option.new(nil,nil,nil,{:args => '[<h> <w>]'})
    
    { a => [false, false],
      b => [false, true],
      c => [true, true]
    }.each do |opt, result|
      assert_equal result, opt.args.map {|i| i.optional? }
      assert_equal [:h, :w], opt.args.map {|i| i.name }
    end
  end
  
  def test_parsing_invalid_argument_string
    o = Clive::Option.new(nil, nil)
    assert_raises Clive::InvalidArgumentString do
      o.parse_args("invalid")
    end
  end
  
  def test_requires_arguments
    y = Clive::Option.new(nil,nil,nil,{:args => '<arg>'})
    assert y.requires_arguments?
    n = Clive::Option.new(nil,nil,nil,{:args => '[<arg>]'})
    refute n.requires_arguments?
    o = Clive::Option.new(nil,nil)
    refute o.requires_arguments?
  end
  
  def test_running
    a = nil
    o = Clive::Option.new(nil,nil) { a = "hello" }
    o.run
    assert_equal "hello", a
  end
  
  def test_running_with_arguments
    a = nil
    o = Clive::Option.new(nil,nil,nil,{:args => '<h> <w>'}) {|h,w| a = [h,w] }
    o.run([5, 10])
    assert_equal [5,10], a
    
    o = Clive::Option.new(nil,nil,nil,{:args => '<size>'}) { a = size }
    o.run([50])
    assert_equal 50, a
  end

end