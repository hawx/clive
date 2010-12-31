$: << File.join(File.dirname(__FILE__), '..') # remove this line after

require 'clive/exceptions'
require 'clive/tokens'
require 'clive/ext'

require 'clive/option'
require 'clive/command'
require 'clive/switch'
require 'clive/flag'
require 'clive/bool'

require 'clive/output'
require 'clive/formatter'

module Clive

  # A module wrapping the command line parsing of clive. In the future this
  # will be the only way of using clive.
  #
  # @example
  #
  #   require 'clive/parser'
  # 
  #   class CLI
  #     include Clive::Parser
  #     option_hash :opts
  #   
  #     switch :v, :verbose, "Run verbosely" do
  #       opts[:verbose] = true
  #     end
  #   end
  #
  #   CLI.parse ARGV
  #   p CLI.opts
  #
  module Parser
    
    # When the module is included we need to keep track of the new class it
    # is now in and we need to create a new base command. So here instance 
    # variables are set directly in the new class, and the class is made to
    # extend the methods in Parser so they are available as class methods.
    # 
    def self.included(klass)
      klass.instance_variable_set("@klass", klass)
      klass.extend(self)
      klass.instance_variable_set "@base", Clive::Command.new(true)
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
    
    # @see Clive::Command#help
    def help(*args)
      base.help(*args)
    end
    
    # @see Clive::Command#help_formatter
    def help_formatter(*args, &block)
      base.help_formatter(*args, &block)
    end
    
    # Create a new hash which is accessible to the options in the new class
    # but can also be accessed from outside the class. Defines getters and 
    # setters for the symbols given, and sets their initial value to +{}+.
    #
    # @param args [Symbol]
    #
    def option_hash(*args)
      args.each do |arg|
        @klass.meta_def(arg) do
          instance_variable_get("@#{arg}")
        end
        @klass.meta_def("#{arg}=") do |val|
          instance_variable_set("@#{arg}", val)
        end
        instance_variable_set("@#{arg}", {})
      end
    end

  end
end
