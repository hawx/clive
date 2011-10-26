module Clive

  # A command allows you to separate groups of commands under their own
  # namespace. But it can also take arguments like an Option, though 
  # instead of executing the block passed to it executes the block passed
  # to {#action}.
  #
  # @example
  #
  #   class CLI
  #     include Clive
  #
  #     command :new, arg: '<dir>' do
  #       # definitions
  #       bool :force
  #
  #       action do |dir|
  #         # code
  #       end
  #     end
  #   end
  #
  #   # call with
  #   #   ./file.rb new ~/somewhere --force
  #   # or
  #   #   ./file.rb new --force ~/somewhere
  #
  class Command < Option
  
    attr_reader :names, :options
    
    OPT_KEYS = Option::OPT_KEYS + [:formatter, :help]
    
    def self.create(*args, &block)
      instance = new(*args, &block)
      instance.run_block
      instance
    end
  
    # @param names [Array[Symbol]]
    #   Names that the Command can be ran with.
    #
    # @param desc [String]
    #   Description of the Command, this is shown in help and will be wrapped properly.
    #
    # @param opts [Hash]
    # @option opts [Boolean] :head
    #   If option should be at top of help list.
    #
    # @option opts [Boolean] :tail
    #   If option should be at bottom of help list.
    #
    # @option opts [String] :args
    #   Arguments that the option takes. See {Argument}.
    #
    # @option opts [Type, Array[Type]] :as
    #   The class the argument(s) should be cast to. See {Type}.
    #
    # @option opts [#match, Array[#match]] :match
    #   Regular expression that the argument(s) must match.
    #
    # @option opts [#include?, Array[#include?]] :in
    #   Collection that argument(s) must be in.
    #
    # @option opts :default
    #   Default value that is used if argument is not given.
    #
    # @option opts :group
    #   Name of the group this option belongs to. This is actually set when 
    #   {Command#group} is used.
    #
    # @option opts [#to_s, #header=, #footer=, #options=, #commands=] :formatter
    #   Help formatter to use for this command, defaults to top-level formatter.
    #
    # @option opts [Boolean] :help
    #   Whether to add a '-h, --help' option to this command which displays help.
    #   
    def initialize(names=[], description="", opts={}, &block)
      @names = names.sort
      @description = description
      @_block = block
      @opts, @args = ArgumentParser.new(opts, OPT_KEYS).to_a
      @opts = DEFAULTS.merge(@opts)
      
      @options = []
      
      # Create basic header "Usage: filename commandname(s) [options]
      @header = "Usage: #{File.basename($0)} #{to_s} [options]"
      @footer = ""
      
      @_group = nil
      
      add_help_option
      
      current_desc
    end

    # @return [Symbol] Single name to use when referring specifically to this command.
    def name
      names.first
    end
    
    # @return [String]
    def to_s
      names.join(',')
    end
    
    # Runs the block that was given to {Command#initialize} within the context of the 
    # command. The state hash is passed (and returned) so that {#set} works outside
    # of {Runner} allowing default values to be set.
    #
    # @param state [Hash] The newly created (usually) state for the command.
    # @return [Hash] The returned hash is used for the state of the command.
    def run_block(state={})
      if @_block
        @state = state
        instance_exec(&@_block)
        @state
      else
        {}
      end
    end
    
    # Set the header for {#help}.
    # @param [String]
    def header(val)
      @header = val
    end
    
    # Set the footer for {#help}.
    # @param [String]
    def footer(val)
      @footer = val
    end
    
    # @see Clive::Option::Runner.set
    def set(key, value)
      @state[key] = value
    end
    
    # @overload option(short=nil, long=nil, description=current_desc, opts={}, &block)
    #   Creates a new Option in the Command. Either +short+ or +long+ must be set.
    #   @param short [Symbol] The short name for the option (:a would become +-a+)
    #   @param long [Symbol] The long name for the option (:add would become +--add+)
    #   @param description [String] Description of the option
    #   @param opts [Hash] Options to create the Option with, see {Option#initialize}
    #
    def option(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when ::Symbol then ns << i
          when ::String then d = i
          when ::Hash   then o = i
        end
      end
      @options << Option.new(ns, d, ({:group => @_group}).merge(o), &block)
    end
    alias_method :opt, :option
    
    # @overload boolean(short=nil, long=nil, description=current_desc, opts={}, &block)
    #   Creates a new Option in the Command which responds to calls with a 'no-' prefix.
    #   +long+ must be set.
    #   @param short [Symbol] The short name for the option (:a would become +-a+)
    #   @param long [Symbol] The long name for the option (:add would become +--add+)
    #   @param description [String] Description of the option
    #   @param opts [Hash] Options to create the Option with, see {Option#initialize}
    #
    def boolean(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when ::Symbol then ns << i
          when ::String then d = i
          when ::Hash   then o = i
        end
      end
      @options << Option.new(ns, d, ({:group => @_group, :boolean => true}).merge(o), &block)
    end
    alias_method :bool, :boolean
    
    # If an argument is given it will set the description to that, otherwise it will
    # return the description for the command.
    # 
    # @param arg [String]
    def description(arg=nil)
      if arg
        @_last_desc = arg
      else
        @description
      end
    end
    alias_method :desc, :description
    
    # The action block is the block which will be executed with any arguments that
    # are found for it. It sets +@block+ so that {Option#run} does not have to be redefined.
    def action(&block)
      @block = block
    end
    
    # Finds the option represented by +arg+, this can either be the long name +--opt+
    # or the short name +-o+, if the option can't be found +nil+ is returned.
    #
    # @param arg [String]
    # @return [Option, nil]
    def find(arg)
      if arg[0..1] == '--'
        find_option(arg[2..-1].gsub('-', '_').to_sym)
      elsif arg[0..0] == '-'
        find_option(arg[1..-1].to_sym)
      end
    end
    alias_method :[], :find
    
    # Attempts to find the option represented by the string +arg+, returns true if
    # it exists and false if not.
    #
    # @param arg [String]
    # @example
    #   
    #   a = Command.new [:command] do
    #     bool :force
    #     bool :auto
    #   end
    #  
    #   a.has?('--force')    #=> true
    #   a.has?('--auto')     #=> true
    #   a.has?('--no-auto')  #=> false
    #   a.has?('--not-real') #=> false
    #   
    def has?(arg)
      !!find(arg)
    end
    
    # Finds the option with the name given by +arg+, this must be in Symbol form so
    # does not have a dash before it. As with {#find} if the option does not exist +nil+
    # will be returned.
    #
    # @param arg [Symbol]
    # @return [Option, nil]
    def find_option(arg)
      @options.find do |opt| 
        if opt.names.include?(arg)
          true
        else
          false
        end
      end
    end
    
    # Attempts to find the option with the Symbol name given, returns true if the option
    # exists and false if not.
    #
    # @param arg [Symbol]
    def has_option?(arg)
      !!find_option(arg)
    end
    
    # Set the group name for all options defined after it.
    #
    # @param name [String]
    # @example
    #
    #   group 'Files'
    #   opt :move,   'Moves a file',   args: '<from> <to>'
    #   opt :delete, 'Deletes a file', arg:  '<file>'
    #   opt :create, 'Creates a file', arg:  '<name>'
    #
    #   group 'Network'
    #   opt :upload,   'Uploads everything'
    #   opt :download, 'Downloads everyhting'
    #
    def group(name)
      @_group = name
    end
    
    # Sugar for +group(nil)+
    def end_group
      group nil
    end
    
    # @see Formatter
    # @return [String] Help string for this command.
    def help
      f = @opts[:formatter]
      f.header   = @header
      f.footer   = @footer
      f.commands = @commands if @commands
      f.options  = @options
      
      f.to_s
    end    

    private
    
    def set_state(state, args)
      state[:args] = (@args.max <= 1 ? args[0] : args)
      state
    end
    
    # Adds the '--help' option to the Command instance if it should be added.
    def add_help_option
      if @opts[:help] && !has_option?(:help)
        h = self # bind self so that it can be called in the block
        self.option(:h, :help, "Display this help message", :tail => true) do
          puts h.help
          exit 0
        end
      end
    end
    
    # @return [String]
    #   Returns the last description to be set with {#description}, it then clears the
    #   stored description so that it is not returned twice.
    def current_desc
      r = @_last_desc
      @_last_desc = ""
      r
    end
    
  end
end
