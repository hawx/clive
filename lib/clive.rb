$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'clive/switches'
require 'clive/flags'
require 'clive/commands'
require 'debug'

# Clive is a simple dsl for creating command line interfaces
#
# @example Simple Example
#
#   opts = {}
#   c = Clive.new do
#     switch(:v, :verbose, "Run verbosely") {
#       opts[:verbose] = true
#     }
#   end
#   c.parse(ARGV)
#
class Clive
  attr_accessor :switches, :flags, :commands, :arguments, :argv
  
  # Creates a new Clive instance
  # 
  # @yield Takes a block that is run through to find switches, flags, etc
  def initialize(&block)
    @switches = Switches.new
    @flags = Flags.new
    @commands = Commands.new
    @arguments = []
  
    self.instance_eval(&block)
  end
  
  # Parse the ARGV passed from the command line
  def parse(argv)
    tokens = tokens(argv)
    
    tokens.each do |i|
      k, v = i[0], i[1]
      case k
      when :command
        v.run(i[2])
      when :switch
        v.run
      when :flag
        v.run(i[2]||'not working')
      when :argument
        # nothing
        # Should really get these passed to flags!
      end
    end
    
  end
  
  include SwitchHelper
  include FlagHelper
  include CommandHelper
  
  # Turn into simple tokens that have been split up into logical parts
  #
  # @example
  #
  #   c.pre_tokens(["add", "-al", "--verbose"])
  #   #=> [[:word, "add"], [:short, "a"], [:short, "l"], [:long, "verbose"]]
  def pre_tokens(arg)
    tokens = []
    arg.each do |i|
      if i[0..1] == "--"
        if i.include?('=')
          a, b = i[2..i.length].split('=')
          tokens << [:long, a] << [:word, b]
        else
          tokens << [:long, i[2..i.length]]
        end
      elsif i[0] == "-"
        i[1..i.length].split('').each do |j|
          tokens << [:short, j]
        end
      else
        tokens << [:word, i]
      end
    end
    tokens
  end
  
  # Turns the command line input into a series of tokens
  #
  # @example
  #
  #   c.tokenize(["add", "-al", "--verbose"])
  #   #=> [[:command, #<Clive::Command>, ...args...], [:switch, "a", 
  #        #<Clive::Switch>], [:switch, "l", #<Clive::Switch>], [:switch, 
  #        "verbose", #<Clive::Switch>]]
  def tokens(arg)
    tokens = []
    pre = pre_tokens(arg)
    command = nil
    pre.each do |i|
      k, v = i[0], i[1]
      case k
      when :word
        if @commands[v]
          command = @commands[v]
          pre -= [[:word, v]]
        end
      end
    end
    
    if command
      command.parse
      # tokenify the command
      tokens << [:command, command, command.tokens(pre)]
      pre = command.argv
    end
    
    pre.each do |i|
      k, v = i[0], i[1]
      case k
      when :short, :long
        if switch = @switches[v]
          tokens << [:switch, switch]
        elsif flag = @flags[v]
          tokens << [:flag, flag]
        else
          raise "error, flag/switch '#{v}' does not exist"
        end
      when :word
        case tokens.last[0]
        when :flag
          tokens.last[2] = v
        else
          tokens << [:argument, v]
        end
      end
    end
    
    tokens
  end

  # Anything that is not a switch, flag or command
  class Argument
    attr_accessor :value
    
    def initialize(value)
      @value = value
    end
  end

end

c = Clive.new do
  flag(:t, :type) {|i| puts i}
end

c.parse(["--type=big"])
