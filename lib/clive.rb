$: << File.dirname(__FILE__)

require 'clive/core_ext'
require 'clive/error'
require 'clive/output'
require 'clive/version'

require 'clive/type'
require 'clive/argument'
require 'clive/option'
require 'clive/command'
require 'clive/parser'


module Clive

  # TopCommand is the top command. It doesn't have a name, the class that
  # includes {Clive} will delegate methods to an instance of this class.
  class TopCommand < Command
    attr_reader :commands
  
    def initialize
      @names    = []
      @options  = []
      @commands = []
      
      # Create basic header "Usage: filename [command] [options]
      @header = "Usage: #{File.basename($0)} [command] [options]\n\n"
      @footer = nil
      
      self.option(:h, :help, "Display this help message", :tail => true) do
        puts self.help
        exit 0
      end
      
      self.command(:help, 'Display help', :arg => '[<command>]', :tail => true)
      
      current_desc
    end
    
    def run(argv, opts={})
      Clive::Parser.new(self).parse(argv, opts)
    end
    
    def command(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when Symbol then ns << i
          when String then d = i
          when Hash   then o = i
        end
      end
      @commands << Command.new(ns, d, o, &block)
    end
    
    # @see Command#find
    def find(arg)
      if arg[0] == '-'
        super
      else
        find_command(arg.to_sym)
      end
    end
    
    # @param arg [Symbol]
    def find_command(arg)
      @commands.find {|i| i.names.include?(arg) }
    end
    
    # @param arg [Symbol]
    def has_command?(arg)
      !!find_command(arg)
    end
  end

  # When included need to set create a {TopCommand} in the class and
  # save it in an instance variable, then the necessary methods can
  # be aliased to call it. Also adds a reader method for it as {#base}
  # and extends with {Type::Lookup}.
  def self.extended(other)
    other.instance_variable_set :@base,  Clive::TopCommand.new
    other.class.send :attr_reader, :base
    other.extend Type::Lookup
    
    # List of common command methods that should be defined for performance
    common_methods = [:opt, :option, :desc, :description, :command, 
                      :run, :has?, :find, :[]]
    
    str = common_methods.map do |meth|
      <<-EOS
        def #{meth}(*args, &block)
          @base.#{meth}(*args, &block)
        end
      EOS
    end.join("\n")

    other.instance_eval str
  end

  def self.included(other)
    other.extend(self)
  end
  
  def method_missing(sym, *args, &block)
    if @base.respond_to?(sym)
      @base.send(sym, *args, &block)
    else
      super
    end
  end
  
  def respond_to_missing?(sym)
    @base.respond_to?(sym)
  end

end
