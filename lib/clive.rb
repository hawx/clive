$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'clive/exceptions'
require 'clive/tokens'
require 'clive/ext'

require 'clive/option'
require 'clive/command'
require 'clive/switch'
require 'clive/flag'
require 'clive/bool'

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
  
  def bools
    @base.bools
  end
  
end

