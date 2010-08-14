$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'clive/switches'
require 'clive/flags'
require 'clive/commands'

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
  
end
