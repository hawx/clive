class Clive
  
  # A string which describes the command to execute
  #   eg. git add
  #       git pull
  #
  class Command < Option
    
    attr_accessor :options, :commands
    attr_accessor :argv, :base
    attr_accessor :header, :footer
    
    # Create a new Command instance
    #
    # @overload initialize(base, &block)
    #   Creates a new base Command to house everything else
    #   @param [Boolean] base whether the command is the base
    #
    # @overload initialize(name, desc, &block)
    #   Creates a new Command as part of the base Command
    #   @param [Symbol] name the name of the command
    #   @param [String] desc the description of the command
    #
    # @yield A block to run, containing switches, flags and commands
    #
    def initialize(*args, &block)
      @argv     = []
      @names    = []
      @base     = false
      @commands = Clive::Array.new
      @options  = Clive::Array.new
    
      if args.length == 1 && args[0] == true
        @base = true
        self.instance_eval(&block)
      else
        args.each do |i|
          case i
          when Symbol
            @names << i.to_s
          when String
            @desc = i
          end
        end
        @block = block
      end
      
      @header = "Usage: #{File.basename($0, '.*')} "
      @header << (@base ? "[commands]" : @names.join(', '))
      @header << " [options]"
      @footer = nil
      
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
          raise MissingArgument.new(v.sort_name) unless i[2] || v.optional
          v.run(i[2])
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
            if r.last && r.last[0] == :flag && r.last[2].nil?
              r.last[2] = v
            else
              r << [:argument, v]
            end
          else
            raise InvalidOption.new(v)
          end
        end
      end
      r
    end
      
      
  #### CREATION HELPERS #### 
  
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
      @commands << Command.new(*args, &block)
    end
    
    # Add a new switch to +@switches+
    # @see Switch#initialize
    def switch(*args, &block)
      @options << Switch.new(*args, &block)
    end

    # Adds a new flag to +@flags+
    # @see Flag#initialize
    def flag(*args, &block)
      @options << Flag.new(*args, &block)
    end
    
    # Creates a boolean switch. This is done by adding two switches of
    # Bool type to +@switches+, one is created normally the other has
    # "no-" appended to the long name and has no short name.
    #
    # @see Bool#initialize
    def bool(*args, &block)
      @options << Bool.new(*args, true, &block)
      @options << Bool.new(*args, false, &block)
    end
    alias_method :boolean, :bool
    
  #### HELP STUFF ####
    
    # This actually creates a switch with "-h" and "--help" that controls
    # the help on this command.
    def build_help
      @options << Switch.new(:h, :help, "Display help") do
        puts self.help
        exit 0
      end
    end
    
    # Set the header
    def header(val)
      @header = val
    end
    
    # Set the footer
    def footer(val)
      @footer = val
    end
    
    def summary(width=30, prepend=5)
      a = @names.sort.join(', ')
      b = @desc
      s = spaces(width-a.length)
      p = spaces(prepend)
      "#{p}#{a}#{s}#{b}"
    end
    
    # Generate the summary for help, show all flags and switches, but do not
    # show the flags and switches within each command. Should also prepend the
    # header and append the footer if set.
    def help(width=30, prepend=5)
      summary = "#{@header}\n"
      
      if @options.length > 0
        summary << "\n Options:\n"
        @options.sort.each do |i|
          next if i.names.include?("help")
          summary << i.summary(width, prepend) << "\n" if i.summary
        end
      end
      
      if @commands.length > 0
        summary << "\n Commands:\n"
        @commands.sort.each do |i|
          summary << i.summary(width, prepend) << "\n"
        end
      end
      
      summary << "\n#{@footer}\n" if @footer
     
      summary
    end
    
    
  end
end