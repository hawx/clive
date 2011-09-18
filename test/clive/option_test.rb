$: << File.dirname(__FILE__) + '/..'
require 'helper'

class OptionTest < MiniTest::Unit::TestCase

  def test_head
    h = Clive::Option.new([:a],nil,{:head => true})
    assert h.head?
    refute h.tail?
  end

  def test_tail
    t = Clive::Option.new([:a],nil,{:tail => true})
    assert t.tail?
    refute t.head?
  end

  def test_parsing_argument_string
    a = Clive::Option.new([:a],nil,{:args => '<h> <w>'})
    b = Clive::Option.new([:a],nil,{:args => '<h> [<w>]'})
    c = Clive::Option.new([:a],nil,{:args => '[<h> <w>]'})

    [[ a, [false, false] ],
     [ b, [false, true]  ],
     [ c, [true,  true]  ]
    ].each do |opt, result|
      assert_equal result, opt.args.map {|i| i.optional? }
      assert_equal [:h, :w], opt.args.map {|i| i.name }
    end
  end

  def test_parsing_invalid_argument_string
    assert_raises Clive::InvalidArgumentString do
      Clive::Option.new([:a], nil, {:args => 'invalid'})
    end
  end

  def test_running
    a = nil
    o = Clive::Option.new([:a]) { a = "hello" }
    o.run({})
    assert_equal "hello", a
  end

  def test_running_with_arguments
    a = nil
    o = Clive::Option.new([:a],nil,{:args => '<h> <w>'}) {|h,w| a = [h,w] }
    o.run({}, [5, 10])
    assert_equal [5,10], a

    o = Clive::Option.new([:a],nil,{:args => '<size>'}) { a = size }
    o.run({}, [50])
    assert_equal 50, a
  end

  def test_default_argument_value
    o = Clive::Option.new([:name], "", {:default => "John"})
    o.run({})
  end

  def test_infer_needs_argument_with_in
    o = Clive::Option.new([:T, :type], "", {:in => %w(small medium large)})
    assert_equal 1, o.args.size
    assert_argument [:arg, false, nil, nil, %w(small medium large)], o.args.first

    o = Clive::Option.new([:T, :type], "", {:in => [%w(small medium large), %w(wide thin)]})
    assert_equal 2, o.args.size
    assert_argument [:arg, false, nil, nil, %w(small medium large)], o.args[0]
    assert_argument [:arg, false, nil, nil, %w(wide thin)], o.args[1]
  end

  def test_infer_needs_argument_with_match
    o = Clive::Option.new([:T, :type], "", {:match => /\d+/})
    assert_equal 1, o.args.size
    assert_argument [:arg, false, nil, /\d+/, nil], o.args.first

    o = Clive::Option.new([:T, :type], "", {:match => [/\d+/, /\d+/, /\d+/]})
    assert_equal 3, o.args.size
    assert_argument [:arg, false, nil, /\d+/, nil], o.args[0]
    assert_argument [:arg, false, nil, /\d+/, nil], o.args[1]
    assert_argument [:arg, false, nil, /\d+/, nil], o.args[2]
  end


  def test_infer_needs_argument_with_as
    o = Clive::Option.new([:T, :type], "", {:as => Symbol})
    assert_equal 1, o.args.size
    assert_argument [:arg, false, Clive::Type::Symbol, nil, nil], o.args.first

    o = Clive::Option.new([:T, :type], "", {:as => [String, Integer]})
    assert_equal 2, o.args.size
    assert_argument [:arg, false, Clive::Type::String, nil, nil], o.args[0]
    assert_argument [:arg, false, Clive::Type::Integer, nil, nil], o.args[1]
  end

  def test_infer_needs_argument_with_default
    o = Clive::Option.new([:T, :type], "", {:default => "large"})
    assert_equal 1, o.args.size
    assert_argument [:arg, true, nil, nil, nil], o.args.first

    o = Clive::Option.new([:T, :type], "", {:default => ["large", 5]})
    assert_equal 2, o.args.size
    assert_argument [:arg, true, nil, nil, nil], o.args[0]
    assert_argument [:arg, true, nil, nil, nil], o.args[1]
  end

  def test_infers_arguments_properly_with_multiple_options
    o = Clive::Option.new([:T, :type], "", {:default => "large", :as => Symbol})
    assert_equal 1, o.args.size
    assert_argument [:arg, true, Clive::Type::Symbol, nil, nil], o.args.first
  end
  
  def test_comparisons_work
    a = Clive::Option.new([:a])
    b = Clive::Option.new([:b])
    
    assert a < b
    assert b > a
    assert a == a.dup
    
    assert_equal [a, b], [b, a].sort
  end
  
  def test_comparison_with_heads_and_tails_work
    a = Clive::Option.new([:a])
    a_head = Clive::Option.new([:a], '', {:head => true})
    a_tail = Clive::Option.new([:a], '', {:tail => true})
    b = Clive::Option.new([:b], '')
    b_head = Clive::Option.new([:b], '', {:head => true})
    b_tail = Clive::Option.new([:b], '', {:tail => true})
    
    assert a_head < a
    assert a_tail > a
    
    assert a_head < b
    assert a_tail > b
    
    assert a > b_head
    assert a < b_tail
    
    assert a_head < b_head
    assert a_tail < b_tail
    
    assert_equal [a_head, b_head, a, b, a_tail, b_tail], [a, a_head, a_tail, b, b_head, b_tail].sort
  end
  
  # TODO
  def test_can_add_infinite_args
    o = Clive::Option.new([:add], "", {:args => "<item>..."})
    assert_equal Infinite, o.args.size
    assert_argument [:arg1, false, nil, nil, nil], o.args.first
  end

end
