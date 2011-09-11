module Clive

  # A command is a subcommand that allows you to separate options under it's 
  # namespace, it can also take arguments but does not execute the block with
  # their values but instead another block defined with #action.
  #
  # @example
  #
  #   class CLI
  #     include Clive
  #
  #     command :new, arg: '<dir>' do
  #       # opt definitions
  #       opt :force, as: Boolean
  #
  #       action do |dir|
  #         # code
  #       end
  #     end
  #   end
  #
  #   # call with
  #   #   file.rb new ~/somewhere --force
  #
  class Command < Option
  
    attr_reader :names, :options
  
    # @param names [Array[Symbol]]
    #   Names that the Command can be ran with.
    #
    # @param desc [String]
    #   Description of the Command, this is shown in help and will be wrapped properly.
    #
    # @param opts [Hash] The options available for commands are the same as for Options
    #   see {Option#initialize} for details.
    #
    def initialize(names, description="", opts={}, &block)
      @names = names.sort
      @description = description
      @_block = block
      
      @opts, @args = do_options(opts)
      
      @options = []
      
      # Create basic header "Usage: filename commandname(s) [options]
      @header = "Usage: #{File.basename($0)} #{@names.join(', ')} [options]"
      @footer = nil
      
      self.option(:h, :help, "Display this help message", :tail => true) do
        puts self.help
        exit 0
      end
      
      current_desc
    end
    
    # @return [Symbol] Single name to use when referring specifically to this command.
    def name
      names.first
    end
    
    # @return [String]
    def to_s
      names.join(', ')
    end
    
    # Runs the block that was given to {Command#initialize} within the context of the 
    # command.
    def run_block
      instance_exec(&@_block) if @_block
    end
    
    # @return [String]
    #   Returns the last description to be set with {#description}, it then clears the
    #   stored description so that it is not returned twice.
    def current_desc
      r = @_last_desc
      @_last_desc = ""
      r
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
    
    # Creates a new Option in the Command.
    #
    # @overload option(short=nil, long=nil, description=current_desc, opts={}, &block)
    #   Creates a new Option. Either short or long must be set.
    #   @param short [Symbol] The short name for the option (:a would become +-a+)
    #   @param long [Symbol] The long name for the option (:add would become +--add+)
    #   @param description [String] Description of the option
    #   @param opts [Hash] Options to create the Option with, see {Option#initialize}
    #
    def option(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when Symbol then ns << i
          when String then d = i
          when Hash   then o = i
        end
      end
      @options << Option.new(ns, d, o, &block)
    end
    alias_method :opt, :option
    
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
        find_option(arg[2..-1].symbolify)
      elsif arg[0..0] == '-'
        find_option(arg[1..-1].to_sym)
      end
    end
    alias_method :[], :find
    
    # Attempts to find the option represented by the string +arg+, returns true if
    # it exists and false if not.
    #
    # @param arg [String]
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
      @options.find {|opt| opt.names.include?(arg) }
    end
    
    # Attempts to find the option with the Symbol name given, returns true if the option
    # exists and false if not.
    #
    # @param arg [Symbol]
    def has_option?(arg)
      !!find_option(arg)
    end
    
    # Builds the help string.
    # @see Formatter
    # @return [String]
    def help
      Formatter.new(@header, @footer, @commands, @options)
    end    
    
    def set_state(state, args)
      state[:args] = (max_args <= 1 ? args[0] : args)
      state
    end
    
  end
end
