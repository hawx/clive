require 'clive/parser'
require 'clive/output'

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
#   # app -v
#   #=> {:verbose => true}
#
# @example Class Style with Inheritence
#
#   opts = {}
#   class BasicCommands < Clive
#     switch :basic do
#       p "basic"
#     end
#   end
#
#   class SubCommands < BasicCommands
#     switch :sub do
#       p "sub"
#     end
#   end
#
#   SubCommands.parse(ARGV)
#   # app --basic --sub
#   #=> "basic"
#   #=> "sub"
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
#   # app add framework=blueprint --force --verbose
#   #=> {:add => {:framework => ['blueprint'], :force => true}, :verbose => true}
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
  
# @group Clive Class Methods

  @@base = Clive::Command.new(true)

  def self.flag(*args, &block)
    @@base.flag(*args, &block)
  end
  
  def self.switch(*args, &block)
    @@base.switch(*args, &block)
  end
  
  def self.command(*args, &block)
    @@base.command(*args, &block)
  end
  
  def self.bool(*args, &block)
    @@base.bool(*args, &block)
  end
  
  def self.parse(argv)
    @@base.run(argv)
  end
  
end
