$: << File.dirname(__FILE__)

# Ruby 1.8.7 and others
unless :a_symbol.respond_to?(:<=>)
  class Symbol
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end

require 'clive/error'
require 'clive/output'
require 'clive/version'
require 'clive/aliased_hash'

require 'clive/formatter'
require 'clive/formatter/plain'
require 'clive/formatter/colour'
require 'clive/type'
require 'clive/argument'
require 'clive/arguments'
require 'clive/arguments/parser'
require 'clive/option/argument_parser'
require 'clive/option/runner'
require 'clive/option'
require 'clive/command'
require 'clive/parser'

# Clive is a DSL for creating command line interfaces. Extend a class with it
# to use.
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
    
    OPT_KEYS = Command::OPT_KEYS + [:help_command, :debug]
    
    DEFAULTS = {
      :formatter => Formatter::Colour.new,
      :help => true,
      :help_command => true
    }
    
    # These options should be copied into each command that is created.
    GLOBAL_OPTIONS = [:formatter, :help]
    
    # Never create an instance of this yourself. Extend Clive, then call #run.
    def initialize
      @names    = []
      @options  = []
      @commands = []
      
      # Create basic header "Usage: filename [command] [options]
      @header = "Usage: #{File.basename($0)} [command] [options]"
      @footer = ""
      @opts = DEFAULTS
      @_group = nil
      
      # Need to keep a state before #run is called so #set works.
      @pre_state = {}

      current_desc
    end
    
    # Need to define #set here for the class that extends Clive.
    # @see Option::Runner#set
    def set(key, value)
      @pre_state[key] = value
    end
    
    def run(argv, opts={})
      opts = ArgumentParser.new(opts, OPT_KEYS).opts
      @opts = DEFAULTS.merge(opts)
      
      add_help_option
      add_help_command
      
      Clive::Parser.new(self).parse(argv, @pre_state, opts)
    end

    # Creates a new Command.
    #
    # @overload option(names=[], description=current_desc, opts={}, &block)
    #   Creates a new Command.
    #   @param names [Array<Symbol>] Names that the command can be called with.
    #   @param description [String] Description of the command.
    #   @param opts [Hash] Options to be passed to the new Command, see {Command#initialize}.
    #
    def command(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when ::Symbol then ns << i
          when ::String then d = i
          when ::Hash   then o = i
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
    
    # Adds the help command, which accepts the name of a command to display help
    # for, to this if it is wanted.
    def add_help_command
      if @opts[:help] && @opts[:help_command] && !has_command?(:help)
        self.command(:help, 'Display help', :arg => '[<command>]', :tail => true)
      end
    end
    
  end

  # This sets up a {TopCommand} instance in +other+ which method calls
  # are then forwarded to. It also defines a +#top+ method which will
  # return this instance.
  def self.extended(other)
    other.instance_variable_set :@top,  Clive::TopCommand.new
    other.class.send :attr_reader, :top
    other.extend Type::Lookup
    
    # Need to define .desc or Rake will give errors
    other.class.send(:define_method, :desc) do |arg|
      @top.desc arg
    end
  end

  # If included act as though it was extended.
  # @see .extended
  def self.included(other)
    other.extend(self)
  end
  
  # Delegate all method calls to the base instance of {TopCommand} if it
  # responds to it, otherwise raise the usual exception.
  def method_missing(sym, *args, &block)
    if @top.respond_to?(sym)
      @top.send(sym, *args, &block)
    else
      super
    end
  end
  
  # Responds to all methods {TopCommand} responds to.
  def respond_to_missing?(sym, include_private)
    @top.respond_to?(sym, include_private)
  end

end
