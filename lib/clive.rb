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
        v.run
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
        tokens << [:long, i[2..i.length]]
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
          tokens << [:flags, flag]
        else
          raise "error, flag/switch '#{v}' does not exist"
        end
      when :word
        tokens << [:argument, v]
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

#c = Clive.new do
#  switch(:print) {}
#  command(:add) {
#    switch(:a) {}
#    switch(:l) {}
#    switch(:verbose) {}
#  }
#  switch(:g) {}
#end

#p c.tokens(["add", "-al", "--verbose", "--print", "10"])
