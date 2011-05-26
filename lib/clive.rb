require 'ast_ast'
require 'attr_plus'


require 'clive/output'
require 'clive/formatter'
require 'clive/exceptions'
require 'clive/tokens'

require 'clive/option'
require 'clive/command'
require 'clive/switch'
require 'clive/flag'
require 'clive/bool'

require 'clive/parser'


# Clive is a simple dsl for creating command line interfaces
#
# @example Simple Example
#
#   require 'clive'
#
#   class CLI
#     include Clive
#     
#     desc 'A switch'
#     switch :s, :switch do
#       puts "You used a switch"
#     end
#     
#     desc 'A flag'
#     flag :hello, :args => "NAME" do |name|
#       puts "Hello, #{name}"
#     end
#     
#     desc 'True or false'
#     bool :which do |which|
#       case which
#       when true
#         puts "true, yay"
#       when false
#         puts "false, not yay"
#       end
#     end
#     
#     option_list :purchases
#     
#     command :new, :buy do
#       switch :toaster do
#         purchases << :toaster
#       end
#       
#       switch :tv do
#         purchases << :tv
#       end
#     end
#     
#   end
#
#   CLI.parse(ARGV)
#
module Clive
  
  # When the module is included we need to keep track of the new class it
  # is now in and we need to create a new base command. So here instance 
  # variables are set directly in the new class, and the class is made to
  # extend the methods in Parser so they are available as class methods.
  # 
  def self.included(klass)
    klass.instance_variable_set("@klass", klass)
    klass.extend(self)
    klass.instance_variable_set "@base", Clive::Command.setup(klass)
  end
  
  # @return [Clive::Command]
  #   The base command to forward method calls to.
  #
  def base; @base; end
  
  # @see Clive::Command#run
  def parse(argv)
    base.run(argv)
  end
  
  # @see Clive::Command#flag
  def flag(*args, &block)
    base.flag(*args, &block)
  end
  
  # @see Clive::Command#switch
  def switch(*args, &block)
    base.switch(*args, &block)
  end
  
  # @see Clive::Command#command
  def command(*args, &block)
    base.command(*args, &block)
  end
  
  # @see Clive::Command#bool
  def bool(*args, &block)
    base.bool(*args, &block)
  end
  
  # @see Clive::Command#desc
  def desc(*args)
    base.desc(*args)
  end
  
  # @see Clive::Command#help_formatter
  def help_formatter(*args, &block)
    base.help_formatter(*args, &block)
  end
  
  # This is a bit nicer, I think, for defining CLIs.
  def option_var(name, value=nil)
    if value
      @klass.class_attr_accessor name => value
    else
      @klass.class_attr_accessor name
    end
  end
  
  # Create a new hash which is accessible to the options in the new class
  # but can also be accessed from outside the class. Defines getters and 
  # setters for the symbols given, and sets their initial value to +{}+.
  #
  # @param args [Symbol]
  #
  def option_hash(*args)
    args.each do |arg|
      option_var(arg, {})
    end
  end
  
  def option_array(*args)
    args.each do |arg|
      option_var(arg, [])
    end
  end
  alias_method :option_list, :option_array
  
end
