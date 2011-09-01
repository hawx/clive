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
  
    attr_reader :names, :desc, :options
  
    # @param names [Array[Symbol]]
    #   Names that the Command can be ran with.
    #
    # @param desc [String]
    #   Description of the Command, this is shown in help and will be wrapped properly.
    #
    # @param opts [Hash] The options available for commands are the same as for Options
    #   see {Option#initialize} for details.
    #
    def initialize(names, desc="", opts={}, &block)
      @names = names.sort
      @desc  = desc
      @_block = block
      
      @opts, hash = sort_opts(opts)
      
      hash  = args_to_hash(hash)
      hash  = infer_args(hash)
      @args = optify(hash)
      
<<<<<<< HEAD
      self.build_help
    end
    
    # @return [Array] all bools in this command
    def bools
      @options.find_all {|i| i.class == Bool }
    end
    
    # @return [Array] all switches in this command
    def switches
      @options.find_all {|i| i.class == Switch }
    end
    
    # @return [Array] all flags in this command
    def flags
      @options.find_all {|i| i.class == Flag }
    end
    
    # Run the block that was passed to find switches, flags, etc.
    #
    # This should only be called if the command has been called
    # as the block could contain other actions to perform only 
    # when called.
    #
    def find
      return nil if @base || @block.nil?
      self.instance_eval(&@block)
      @block = nil
    end
    
    # Gets the type of the option which corresponds with the name given
    #
    # @param name [String]
    # @return [Constant]
    #
    def type_is?(name)
      find_opt(name).class.name || Clive::Command
=======
      @options = []
      current_desc
>>>>>>> master
    end
    
    # @return [Symbol] Single name to use when referring specifically to this command.
    def name
      names.first
    end
    
    # @return [String]
    def to_s
      names.join(', ')
    end
    
    # Runs the block that was given to Command#initialize within the context of the 
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
    
    # Creates a new Option in the Command.
    #
    # @overload option(short=nil, long=nil, description=current_desc, opts={}, &block)
    #   Creates a new Option
    #   @param short [Symbol] The short name for the option (:a would become +-a+)
    #   @param long [Symbol] The long name for the option (:add would become +--add+)
    #   @param description [String] Description of the option
    #   @param opts [Hash] Options to create the Option with, see Option#initialize
    #
<<<<<<< HEAD
    def __array_to_tokens(arr)
      result = []
      
      arr.each do |a|
        if a[0..1] == "--"
          result << [:option, a[2..-1]]
          
        elsif a[0] == "-"
          a[1..-1].split('').each do |i|
            result << [:option, i]
          end

        else
          result << [:word, a]
        end
      end

      result 
    end
    
    # Converts the set of tokens returned from #array_to_tokens into a tree.
    # This is where we determine whether a +word+ is an argument or command. 
    #
    # @example
    #   tokens_to_tree([[:option, "switch"], [:word, "command"], 
    #                   [:option, "f"], [:word, "arg"]])
    #   #=> [
    #   #     [:switch, #<Clive::Switch [switch]>],
    #   #     [:command, #<Clive::Command [command]>, [
    #   #       [:flag, #<Clive::Flag [f, flag]>, [
    #   #         [:arg, 'arg']
    #   #       ]]
    #   #     ]]
    #   #   ]
    #
    # @param arr [Array]
    # @return [Array]
    #
    def __tokens_to_tree(arr)
      tree = []
      self.find
      
      l = arr.size
      i = 0
      while i < l
        a = arr[i]
        
        if a[0] == :word
          
          last = tree.last || []
          
          if last[0] == :flag
            last[2] ||= []
          end
          
          if command = find_command(a[1])
            if last[0] == :flag              
              if last[2].size < last[1].arg_size(:mandatory)
                last[2] << [:arg, a[1]]
              else
                tree << [:command, command, command.tokens_to_tree(arr[i+1..-1])]
                i = l
              end
            else
              tree << [:command, command, command.tokens_to_tree(arr[i+1..-1])]
              i = l
            end
          else
            if last[0] == :flag && last[2].size < last[1].arg_size(:all)
              last[2] << [:arg, a[1]]
            else
              tree << [:arg, a[1]]
            end  
          end
        else
          tree << [opt_type(a[1]), find_opt(a[1])]
=======
    def option(*args, &block)
      ns, d, o = [], current_desc, {}
      args.each do |i|
        case i
          when Symbol then ns << i
          when String then d = i
          when Hash   then o = i
>>>>>>> master
        end
      end
      @options << Option.new(ns, d, o, &block)
    end
    alias_method :opt, :option
    
    # If an argument is given it will set the description to that, otherwise it will
    # return the description for the command.
    # 
<<<<<<< HEAD
    # @param tree [Array]
    # @return [Array]
    #   Any unused arguments.
    #
    def __run_tree(tree)
      i = 0
      l = tree.size
      r = []
      
      while i < l
        curr = tree[i]
        
        case curr[0]
        when :command
          r << curr[1].run(curr[2])
          
        when :switch
          curr[1].run
          
        when :flag
          args = curr[2].map {|i| i[1] }
          if args.size < curr[1].arg_size(:mandatory)
            raise MissingArgument.new(curr[1].sort_name)
          end
          curr[1].run(args)
          
        when :arg
          r << curr[1]
        end
        
        i += 1
=======
    # @param arg [String]
    def description(arg=nil)
      if arg
        @_last_desc = arg
      else
        @description
>>>>>>> master
      end
    end
    alias_method :desc, :description
    
<<<<<<< HEAD
    
    # Parse the ARGV passed from the command line, and run
    #
    # @param [Array] argv the command line input, usually just +ARGV+
    # @return [Array] any arguments that were present in the input but not used
    #
    def __run(argv=[])
      to_run = argv
      if @base # if not base we will have been passed the parsed tree already
        to_run = tokens_to_tree( array_to_tokens(argv) )
      end
      run_tree(to_run)
=======
    # The action block is the block which will be executed with any arguments that
    # are found for it. It sets +@block+ so that {Option#run} does not have to be redefined.
    def action(&block)
      @block = block
>>>>>>> master
    end
    
    # Why do the general methods take strings not symbols?
    # > So that I can find out which array to check in. Otherwise, if for example,
    # > there was an option and command with the same name you would not know which
    # > to return.
    
    # Finds the option represented by +arg+, this can either be the long name +--opt+
    # or the short name +-o+, if the option can't be found +nil+ is returned.
    #
    # @param arg [String]
    # @return [Option, nil]
    def find(arg)
      if arg[0..1] == '--'
        find_option(arg[2..-1].to_sym)
      elsif arg[0...1] == '-'
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

    # A command is a command
    def command?; true;  end
    # A command is not an option, these methods should be removed!
    def option?;  false; end
    puts "#{__FILE__}:#{__LINE__} remove these methods"
    
  end
end