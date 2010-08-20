$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'clive/tokens'
require 'clive/ext'
require 'clive/option'
require 'clive/switches'
require 'clive/flags'
require 'clive/commands'
require 'clive/booleans'

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

  # general problem with input
  class ParseError < StandardError
    attr_accessor :args, :reason
    
    def initialize(*args)
      @args = args
      @reason = "parse error"
    end
    
    def self.filter_backtrace(array)
      unless $DEBUG
        array = [$0]
      end
      array
    end
    
    def set_backtrace(array)
      super(self.class.filter_backtrace(array))
    end
    
    def message
      @reason + ': ' + args.join(' ')
    end
    alias_method :to_s, :message
  
  end
  
  # a flag has a missing argument
  class MissingArgument < ParseError
    def initialize(*args)
      @args = args
      @reason = "missing argument"
    end
  end
  
  # a option that wasn't defined has been found
  class InvalidOption < ParseError
    def initialize(*args)
      @args = args
      @reason = "invalid option"
    end
  end

  attr_accessor :base
  
  def initialize(&block)
    @base = Command.new(true, &block)
  end
  
  def parse(argv)
    @base.run(argv)
  end
  
  def switches
    @base.switches
  end
  
  def commands
    @base.commands
  end
  
  def flags
    @base.flags
  end
  
  def booleans
    @base.booleans
  end
  
end

