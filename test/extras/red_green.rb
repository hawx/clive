class RedGreenIO
  attr_reader :io

  def initialize(io)
    @io = io
  end

  RED   = "\e[31m"
  GREEN = "\e[32m"
  RESET = "\e[0m"

  def print(o)
    case o
      when '.' then io.print("#{GREEN}#{o}#{RESET}")
      when 'E', 'F' then io.print("#{RED}#{o}#{RESET}")
      else io.print(o)
    end
  end

  def method_missing(msg, *args)
    io.send(msg, *args)
  end
end

MiniTest::Unit.output = RedGreenIO.new(MiniTest::Unit.output)
