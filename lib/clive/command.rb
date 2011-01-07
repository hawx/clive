module Clive
  
  # A string which describes the command to execute
  #   eg. git add
  #       git pull
  #
  class Command < Option
    
    attr_accessor :options, :commands
    attr_accessor :argv, :base
    attr_reader   :names, :current_desc
    
    # Create a new Command instance
    #
    # @overload initialize(base, &block)
    #   Creates a new base Command to house everything else
    #   @param base [Boolean] whether the command is the base
    #
    # @overload initialize(names, desc, &block)
    #   Creates a new Command as part of the base Command
    #   @param names [Symbol] the name of the command
    #   @param desc [String] the description of the command
    #
    # @yield A block to run, containing switches, flags and commands
    #
    def initialize(*args, &block)
      @argv     = []
      @names    = []
      @base     = false
      @commands = Clive::Array.new
      @options  = Clive::Array.new
      
      @option_missing = Proc.new {|e| raise NoOptionError.new(e)}
    
      if args.length == 1 && args[0] == true
        @base = true
        self.instance_eval(&block) if block_given?
      else
        args.each do |i|
          case i
          when ::Array
            @names = i.map {|i| i.to_s }
          when String
            @desc = i
          end
        end
        @block = block
      end
      
      # Create basic header "Usage: filename [command] [options]
      #                  or "Usage: filename commandname(s) [options]
      @header = "Usage: #{File.basename($0, '.*')} " << 
                (@base ? "[command]" : @names.join(', ')) << 
                " [options]"
                
      @footer = nil
      @current_desc = ""
      help_formatter :default
      
      self.build_help
    end
    
    # @return [Clive::Array] all bools in this command
    def bools
      Clive::Array.new(@options.find_all {|i| i.class == Bool})
    end
    
    # @return [Clive::Array] all switches in this command
    def switches
      Clive::Array.new(@options.find_all {|i| i.class == Switch})
    end
    
    # @return [Clive::Array] all flags in this command
    def flags
      Clive::Array.new(@options.find_all {|i| i.class == Flag})
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
    
    # Parse the ARGV passed from the command line, and run
    #
    # @param [::Array] argv the command line input, usually just +ARGV+
    # @return [::Array] any arguments that were present in the input but not used
    #
    def run(argv=[])
      tokens = argv
      tokens = tokenize(argv) if @base
      
      r = []
      tokens.each do |i|
        k, v = i[0], i[1]
        case k
        when :command
          r << v.run(i[2])
        when :switch
          v.run
        when :flag
          args = i[2..-1]
          opt_args = v.arg_num(true)
          nec_args = v.arg_num(false)
          # check for missing args
          if args.size < nec_args
            raise MissingArgument.new(v.sort_name)
          end
          
          v.run(args)
        when :argument
          r << v
        end
      end
      r.flatten
    end
    
    # Turns the command line input into a series of tokens.
    # It will only raise errors if this is the base command instance.
    #
    # @param [::Array] argv the command line input
    # @return [::Array] a series of tokens
    #
    # @example
    #
    #   c.tokenize(["add", "-al", "--verbose"])
    #   #=> [[:command, #<Clive::Command>, ...args...], [:switch, "a", 
    #        #<Clive::Switch>], [:switch, "l", #<Clive::Switch>], [:switch, 
    #        "verbose", #<Clive::Switch>]]
    #
    def tokenize(argv)
      self.find
      r = []
      tokens = Tokens.new(argv)
      
      pre_command = Tokens.new
      command = nil
      tokens.tokens.each do |i|
        k, v = i[0], i[1]
        # check if a command
        if k == :word && commands[v]
          command = v
          break
        else
          pre_command << i
        end
      end

      post_command = Tokens.new(tokens.array - pre_command - [command])
      pre_command_tokens = parse(pre_command)
      r = pre_command_tokens
      
      if command
        t = commands[command].tokenize(post_command)
        r << [:command, commands[command], t]
      end
      
      r
    end
    
    # This runs through the tokens from Tokens#to_tokens (or similar)
    # and creates a new array with the type of object and the object
    # itself, possibly with an argument in the case of Flag.
    #
    # @param [Tokens] tokens the tokens to run through
    # @return [::Array] of the form 
    #   [[:flag, #<Clive::Flag...>, "word"], [:switch, #<Clive::Switch....
    # @raise [InvalidOption] raised if option given can't be found
    #
    def parse(tokens)
      r = []
      tokens.tokens.each do |i|
        k, v = i[0], i[1]
        if switch = switches[v] || switch = bools[v]
          r << [:switch, switch]
        elsif flag = flags[v]
          r << [:flag, flag]
        else
          if k == :word
            # add to last flag?
            if r.last && r.last[0] == :flag && r.last.size - 2 < r.last[1].arg_size
              r.last.push(v)
            else
              r << [:argument, v]
            end
          else
            @option_missing.call(v)
          end
        end
      end
      r
    end
    
    def to_h
      {
        'names' => @names,
        'desc'  => @desc
      }
    end
  
    
      
  # @group DSL
  
    # Add a new command to +@commands+
    #
    # @overload command(name, ..., desc, &block)
    #   Creates a new command
    #   @param [Symbol] name the name(s) of the command, eg. +:add+ for +git add+
    #   @param [String] desc description of the command
    # 
    # @yield A block to run when the command is called, can contain switches
    #   and flags
    #
    def command(*args, &block)
      @commands << Command.new(args, @current_desc, &block)
      @current_desc = ""
    end
    
    # Add a new switch to +@switches+
    # @see Switch#initialize
    def switch(*args, &block)
      @options << Switch.new(args, @current_desc, &block)
      @current_desc = ""
    end

    # Adds a new flag to +@flags+
    # @see Flag#initialize
    def flag(*args, &block)
      names = []
      arg = []
      args.each do |i|
        if i.is_a? Symbol
          names << i
        else
          if i[:arg]
            arg << i[:arg]
          else
            arg << i[:args]
          end
        end
      end
      @options << Flag.new(names, @current_desc, arg, &block)
      @current_desc = ""
    end
    
    # Creates a boolean switch. This is done by adding two switches of
    # Bool type to +@switches+, one is created normally the other has
    # "no-" appended to the long name and has no short name.
    #
    # @see Bool#initialize
    def bool(*args, &block)
      @options << Bool.new(args, @current_desc, true, &block)
      @options << Bool.new(args, @current_desc, false, &block)
      @current_desc= ""
    end
    
    # Add a description for the next option in the class. Or acts as an 
    # accessor for @desc.
    #
    # @example
    #
    #   class CLI
    #     include Clive::Parser
    #
    #     desc 'Force build docs'
    #     switch :force do
    #       # code
    #     end
    #   end
    #
    def desc(str=nil)
      if str
        @current_desc = str
      else
        @desc
      end
    end
    
    # Define a block to execute when the option to execute cannot be found.
    #
    # @example
    #
    #   class CLI
    #     include Clive::Parser
    #
    #     option_missing do |name|
    #       puts "#{name} couldn't be found"
    #     end
    #
    def option_missing(&block)
      @option_missing = block
    end      
    
    # Set the header
    def header(val)
      @header = val
    end
    
    # Set the footer
    def footer(val)
      @footer = val
    end
    
  # @group Help
    
    # This actually creates a switch with "-h" and "--help" that controls
    # the help on this command.
    def build_help
      @options << Switch.new([:h, :help], "Display help") do
        puts self.help
        exit 0
      end
    end

    # Generate the summary for help, show all flags and switches, but do not
    # show the flags and switches within each command. Should also prepend the
    # header and append the footer if set.
    def help
      @formatter.format(@header, @footer, @commands, @options)
    end
    
    # This allows you to define how the output from #help looks.
    #
    # For this you have access to several tokens which are evaluated in an object
    # with the correct values, this means you are able to use #join on arrays or
    # prepend, etc. The variables (tokens) are:
    #
    # * prepend - a string of spaces as specified when #help_formatter is called
    # * names - an array of names for the option
    # * spaces - a string of spaces to align the descriptions properly
    # * desc - a string of the description for the option
    #
    # And for flags you have access to:
    #
    # * args - an array of arguments for the flag
    # * options - an array of options to choose from
    #
    #
    # @overload help_formatter(args, &block)
    #   Create a new help formatter to use.
    #   @param args [Hash]
    #   @option args [Integer] :width Width before flexible spaces
    #   @option args [Integer] :prepend Width of spaces to prepend with
    #
    # @overload help_formatter(name)
    #   Use an existing help formatter.
    #   @param name [Symbol] name of the formatter (either +:default+ or +:white+)
    #
    #
    # @example
    #   
    #   CLI.help_formatter do |h|
    #
    #     h.switch  "{prepend}{names.join(', ')} {spaces}{desc.grey}"
    #     h.bool    "{prepend}{names.join(', ')} {spaces}{desc.grey}"
    #     h.flag    "{prepend}{names.join(', ')} {args.join(' ')} {spaces}{desc.grey}"
    #     h.command "{prepend}{names.join(', ')} {spaces}{desc.grey}"
    #
    #   end
    #   
    #   
    def help_formatter(*args, &block)    
      if block_given?
        width   = 30
        prepend = 5
      
        unless args.empty?
          args[0].each do |k,v|
            case k
            when :width
              width = v
            when :prepend
              prepend = v
            end
          end
        end
        
        @formatter = Formatter.new(width, prepend)
        block.call(@formatter)
        @formatter
      else
        case args[0]
        when :default
           help_formatter do |h|
            h.switch  "{prepend}{names.join(', ')}  {spaces}{desc.grey}"
            h.bool    "{prepend}{names.join(', ')}  {spaces}{desc.grey}"
            h.flag    "{prepend}{names.join(', ')} {args.join(' ')}  {spaces}" << 
                        "{desc.grey} {options.join('(', ', ', ')').blue.bold}"
            h.command "{prepend}{names.join(', ')}  {spaces}{desc.grey}"
          end
        
        when :white
          help_formatter do |h|
            h.switch  "{prepend}{names.join(', ')}  {spaces}{desc}"
            h.bool    "{prepend}{names.join(', ')}  {spaces}{desc}"
            h.flag    "{prepend}{names.join(', ')} {args.join(' ')}  {spaces}" << 
                        "{desc} {options.join('(', ', ', ')').bold}"
            h.command "{prepend}{names.join(', ')}  {spaces}{desc}"
          end
        
        end
      end
    end
    
  end
end