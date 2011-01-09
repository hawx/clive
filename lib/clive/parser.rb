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
    
    
    # @see http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
    # or because that doesn't exist anymore from this mirror
    # http://viewsourcecode.org/why/hacking/seeingMetaclassesClearly.html
    #
    def meta_def(name, &blk)
      (class << self; self; end).instance_eval { define_method(name, &blk) }
    end
    
    def option_var(name, value=nil)
      @klass.meta_def(name) do
        instance_variable_get("@#{name}")
      end
      @klass.meta_def("#{name}=") do |val|
        instance_variable_set("@#{name}", val)
      end
      instance_variable_set("@#{name}", value)
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
end
