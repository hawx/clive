# Simple test output
#  red   = fail/error
#  green = pass
# I hate minitest/pride, what's wrong with just two colours?
#
class RedGreenIO
  attr_reader :io

  def initialize(io)
    @io = io
  end

  def print(o)
    case o
      when '.' then print_colour(o, 2)
      when 'S' then print_colour(o, 3)
      when 'E', 'F' then print_colour(o, 1)
      else io.print(o)
    end
  end
  
  def print_colour(str, code)
    io.print "\e[3#{code}m#{str}\e[0m"
  end

  def method_missing(msg, *args)
    io.send(msg, *args)
  end
end

MiniTest::Unit.output = RedGreenIO.new(MiniTest::Unit.output)
