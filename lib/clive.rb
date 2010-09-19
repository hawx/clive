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
# @example Non-simple Example
#
#   opts = {}
#   c = Clive.new do
#     bool(:v, :verbose, "Run verbosely") {|i| opts[:verbose] = i}
#     
#     command :add, "Add a new project" do
#       opts[:add] = {}
#       
#       switch(:force, "Force overwrite") {opts[:add][:force] = true}
#       flag :framework, "Add framework" do |i| 
#         opts[:add][:framework] ||= []
#         opts[:add][:framework] << i
#       end
#       
#       command :init, "Initialize the project after creating" do
#         switch(:m, :minimum, "Use minimum settings") {opts[:add][:min] = true}
#         flag(:w, :width) {|i| opts[:add][:width] = i.to_i}
#       end
#     
#     end
#     
#     switch :version, "Show version" do
#       puts "1.0.0"
#       exit
#     end
#   end
#   ARGV = c.parse(ARGV)
#
class Clive
  
  # This is the base command, the only way it differs from a normal command
  # is that it has no name and it's block is executed immediately on creation.
  #
  # @return [Command] the base command
  #   
  attr_accessor :base
  
  def initialize(&block)
    @base = Command.new(true, &block)
  end
  
  # Parse the base command
  def parse(argv)
    @base.run(argv)
  end
  
# @group Base Proxy Methods
  
  # @see Command#switches
  # @return [Array] switches in +base+
  def switches
    @base.switches
  end
  
  # @see Command#commands
  # @return [Array] commands in +base+
  def commands
    @base.commands
  end
  
  # @see Command#flags
  # @return [Array] flags in +base+
  def flags
    @base.flags
  end
  
  # @see Command#bools
  # @return [Array] bools in +base+
  def bools
    @base.bools
  end
  
end
