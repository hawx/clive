$: << File.dirname(__FILE__)

require 'clive/core_ext'
require 'clive/error'
require 'clive/output'
require 'clive/version'

require 'clive/formatter'
require 'clive/type'
require 'clive/argument'
require 'clive/option/argument_parser'
require 'clive/option/runner'
require 'clive/option'
require 'clive/command'
require 'clive/parser'

# Clive is a DSL for creating command line interfaces. Extend a class with it
# (or include it) to use.
#
# @example
#
#   class CLI
#     extend Clive
#
#     opt :working, 'Test if it is working' do
#       puts "YEP!".green
#     end
#   end
#
#   CLI.run ARGV
#
#   # app.rb --working
#   #=> "YEP!"
#
module Clive

  # TopCommand is the top command. It doesn't have a name, the class that
  # includes {Clive} will delegate methods to an instance of this class.
  class TopCommand < Command
    attr_reader :commands
    
    # Never create an instance of this yourself. Extend Clive, then call #run.
    def initialize
      @names    = []
      @options  = []
      @commands = []
      
      # Create basic header "Usage: filename [command] [options]
      @header = "Usage: #{File.basename($0)} [command] [options]\n\n"
      @footer = ""
      @opts = DEFAULTS
      @_group = nil

      current_desc
    end
    
    def run(argv, opts={})
      opts = ArgumentParser.new(opts).opts
      @opts = DEFAULTS.merge(opts)
      
      add_help_option
      add_help_command
      
      Clive::Parser.new(self).parse(argv, opts)
    end

    DEFAULTS = {
      :formatter => ColourFormatter.new,
      :help => true,
      :help_command => true
    }
    
    # These options should be copied into each command created.
    GLOBAL_OPTIONS = [:formatter, :help]

    def command(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when Symbol then ns << i
          when String then d = i
          when Hash   then o = i
        end
      end
      o = DEFAULTS.merge(
        Hash[@opts.find_all {|k,v| GLOBAL_OPTIONS.include?(k) }]
      ).merge(o)
      @commands << Command.new(ns, d, o.merge({:group => @_group}), &block)
    end
    
    # @see Command#find
    def find(arg)
      if arg[0..0] == '-'
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
    
    private
    
    def add_help_command
      if @opts[:help] && @opts[:help_command] && !has_command?(:help)
        self.command(:help, 'Display help', :arg => '[<command>]', :tail => true)
      end
    end
    
  end



  # When included need to create a {TopCommand} instance in the class and
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

  # If included act as though it was extended.
  def self.included(other)
    other.extend(self)
  end
  
  # Delegate all method calls to the base instance of {TopCommand} if it
  # responds to it, otherwise raise the usual exception.
  def method_missing(sym, *args, &block)
    if @base.respond_to?(sym)
      @base.send(sym, *args, &block)
    else
      super
    end
  end
  
  # {#method_missing} responds to all methods that the base instance of 
  # {TopCommand} responds to.
  def respond_to_missing?(sym)
    @base.respond_to?(sym)
  end

end
