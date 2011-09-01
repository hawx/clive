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
      when '.' then io.print("\e[32m#{o}\e[0m")
      when 'E', 'F' then io.print("\e[31m#{o}\e[0m")
      else io.print(o)
    end
  end

  def method_missing(msg, *args)
    io.send(msg, *args)
  end
end

MiniTest::Unit.output = RedGreenIO.new(MiniTest::Unit.output)
