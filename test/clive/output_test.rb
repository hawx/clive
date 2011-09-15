$: << File.dirname(__FILE__) + '/..'
require 'helper'

class OutputTest < MiniTest::Unit::TestCase

  def test_padding_string
    assert_equal 'a----', Clive::Output.pad('a', 5, '-')
  end
  
  def test_wrapping_text
    t = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
    
    r = "Lorem ipsum dolor
   sit amet,
   consectetur
   adipisicing elit,
   sed do eiusmod
   tempor incididunt ut
   labore et dolore
   magna aliqua."
  
    assert_equal r, Clive::Output.wrap_text(t, 3, 23)
  end
  
  def test_gets_terminal_width
    ENV['COLUMNS'] = '80'
    assert_equal 80, Clive::Output.terminal_width
  end

end

class StringTest < MiniTest::Unit::TestCase

  def test_colouring_string
    assert_equal "\e[5mstr\e[0m", "str".colour(5)
  end
  
  def test_mutable_colouring
    s = "str".colour!(5)
    assert_equal "\e[5mstr\e[0m", s
  end
  
  def test_crazy_combinations
    assert_equal "\e[4m\e[5m\e[42m\e[1m\e[91mstr\e[0m", "str".l_red.bold.green_bg.blink.underline
  end
  
  def test_can_clear_colour_codes
    assert_equal "str", "str".red.blue_bg.bold.blink.clear_colours
  end
  
  def test_can_clear_colours_on_object
    s = "str".red.green_bg.bold.blink
    s.clear_colours!
    assert_equal "str", s
  end

end