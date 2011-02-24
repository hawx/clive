module Clive
  
  # A string which describes the command to execute
  #   eg. git add
  #       git pull
  #
  class Command < Option
    
    attr_accessor :options, :commands
    attr_accessor :argv, :base
    attr_reader   :names, :current_desc
    attr_reader   :top_klass
    
    # Create the base Command instance. Replacement for the #initialize
    # overloading.
    #
    def self.setup(klass, &block)
      new([], "", klass, &block)
    end
    
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
    def initialize(names, desc, top_klass, &block)
      @argv      = []
      @names     = names.map {|i| i.to_s }
      @top_klass = top_klass
      @desc      = desc
      @commands  = []
      @options   = []
      @block     = block
      @base      = false
      
      if @names == [] && @desc == ""
        @base = true
        self.instance_eval(&block) if block_given?
      end
      
      @option_missing = Proc.new {|e| raise NoOptionError.new(e)}
      
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
    
    # @return [Array] all bools in this command
    def bools
      @options.find_all {|i| i.class == Bool}
    end
    
    # @return [Array] all switches in this command
    def switches
      @options.find_all {|i| i.class == Switch}
    end
    
    # @return [Array] all flags in this command
    def flags
      @options.find_all {|i| i.class == Flag}
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
    end
    
    def opt_type(name)
      case find_opt(name).class.name
      when "Clive::Switch"
        :switch
      when "Clive::Bool"
        :switch
      when "Clive::Flag"
        :flag
      when "Clive::Command"
        :command
      else
        nil
      end
    end
    
    # Finds the option which has the name given
    #
    # @param name [String]
    # @return [Clive::Option]
    #
    def find_opt(name)
      options.find {|i| i.names.include?(name)}
    end
    
    # Checks whether the string given is the name of a Command or not
    #
    # @param str [String]
    # @return [true, false]
    #
    def is_a_command?(str)
      find_command(str).empty?
    end
    
    # Finds the command which has the name given
    #
    # @param name [String]
    # @return [Clive::Command]
    #
    def find_command(str)
      commands.find {|i| i.names.include?(str)}
    end
    
    # Converts the array of input from the command line into a string of tokens.
    # It replaces instances of the names of flags, switches and bools with the 
    # actual option, but does not affect commands. Instead these are left as +words+.
    #
    # @example
    #
    #   array_to_tokens ['--switch', 'command', '-f', 'arg']
    #   #=> [[:option, "switch"], [:word, "command"], [:option, "f"], [:word, "arg"]]
    #
    # @param arr [Array]
    # @return [Array]
    #
    def array_to_tokens(arr)
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
    def tokens_to_tree(arr)
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
        end

        i += 1
      end

      tree
    end
    
    # Traverses the tree created by #tokens_to_tree and runs the correct options.
    # 
    # @param tree [Array]
    # @return [Array]
    #   Any unused arguments.
    #
    def run_tree(tree)
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
      end
      r.flatten
    end
    
    
    # Parse the ARGV passed from the command line, and run
    #
    # @param [Array] argv the command line input, usually just +ARGV+
    # @return [Array] any arguments that were present in the input but not used
    #
    def run(argv=[])
      to_run = argv
      if @base # if not base we will have been passed the parsed tree already
        to_run = tokens_to_tree( array_to_tokens(argv) )
      end
      run_tree(to_run)
    end
    
    
    def to_h
      {
        'names' => @names,
        'desc'  => @desc
      }
    end
    
    def method_missing(sym, *args, &block)
      if @top_klass.respond_to?(sym)
        @top_klass.send(sym, *args)
      end
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
      @commands << Command.new(args, @current_desc, @top_klass, &block)
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
            arg = i[:arg]
          else
            arg = i[:args]
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
        prepend = 4
      
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
          help_formatter(&HELP_FORMATTERS[:default])
        when :white
          help_formatter(&HELP_FORMATTERS[:white])
        end
      end
    end
    
    HELP_FORMATTERS = {
      :default => lambda do |h|
        h.switch  "{prepend}{names.join(', ')}  {spaces}{desc.grey}"
        h.bool    "{prepend}{names.join(', ')}  {spaces}{desc.grey}"
        h.flag    "{prepend}{names.join(', ')} {args}  {spaces}{desc.grey} {options.blue.bold}"
        h.command "{prepend}{names.join(', ')}  {spaces}{desc.grey}"
      end,
      :white => lambda do |h|
        h.switch  "{prepend}{names.join(', ')}  {spaces}{desc}"
        h.bool    "{prepend}{names.join(', ')}  {spaces}{desc}"
        h.flag    "{prepend}{names.join(', ')} {args}  {spaces}{desc} {options.bold}"
        h.command "{prepend}{names.join(', ')}  {spaces}{desc}"
      end
    }
    
  end
end