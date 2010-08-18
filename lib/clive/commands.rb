class Clive
  
  # A string which describes the command to execute
  #   eg. git add
  #       git pull
  #
  class Command
    
    attr_accessor :switches, :flags, :commands
    attr_accessor :name, :desc, :block, :argv
    attr_accessor :base
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
      @switches = Clive::Array.new
      @flags    = Clive::Array.new
      @commands = Clive::Array.new
    
      if args.length == 1 && args[0] == true
        @base = true
        self.instance_eval(&block)
      else
        @base = false
        args.each do |i|
          case i
          when Symbol
            @name = i.to_s
          when String
            @desc = i
          end
        end
        @block = block
      end
      
      @header = "Usage: #{File.basename($0, '.*')} "
      @header << (@base ? "[commands]" : @name)
      @header << " [options]"
      @footer = nil
      
      self.build_help
    end
    
    # Getter to find booleans
    def booleans
      @switches.find_all {|i| i.is_a?(Boolean)}
    end
    
    # Run the block that was passed to find switches, flags, etc.
    #
    # This should only be called if the command has been called
    # as the block could contain other actions to perform only 
    # when called.
    #
    def find
      return nil if @base
      self.instance_eval(&@block)
    end
    
    # Parse the ARGV passed from the command line, and run
    #
    # @param [Array] argv the command line input, usually just ARGV
    # @return [Array] any arguments that were present in the input but not used
    #
    def run(argv=[])
      tokens = argv
      tokens = tokenize(argv) if @base
      
      r = []
      tokens.each do |i|
        k, v = i[0], i[1]
        case k
        when :command
          v.run(i[2])
        when :switch
          v.run
        when :flag
          raise MissingArgument.new(v.long||v.short) unless i[2] || v.optional
          v.run(i[2])
        when :argument
          r << v
        end
      end
      r
    end
    
    # Turns the command line input into a series of tokens.
    # It will only raise errors if this is the base command instance.
    #
    # @param [Array] argv the command line input
    # @return [Array] a series of tokens
    #
    # @example
    #
    #   c.tokenize(["add", "-al", "--verbose"])
    #   #=> [[:command, #<Clive::Command>, ...args...], [:switch, "a", 
    #        #<Clive::Switch>], [:switch, "l", #<Clive::Switch>], [:switch, 
    #        "verbose", #<Clive::Switch>]]
    #
    def tokenize(argv)
      tokens = []
      pre = Tokens.to_tokens(argv)
      command = nil
      @argv = argv unless @base
      
      pre.each do |i|
        k, v = i[0], i[1]
        case k
        when :word
          if @commands[v]
            command = @commands[v]
            pre -= [[:word, v]]
          end
        end
      end
      
      if command
        command.find
        # tokenify the command
        tokens << [:command, command, command.tokenize(Tokens.to_array(pre))]
        pre = Tokens.to_tokens(command.argv)
      end 
      
      pre.each do |i|
        k, v = i[0], i[1]
        case k
        when :short, :long
          if switch = @switches[v]
            tokens << [:switch, switch]
            pre -= [[k, v]] unless @base
          elsif flag = @flags[v]
            tokens << [:flag, flag]
            pre -= [[k, v]] unless @base
          else
            raise InvalidOption.new(v) if @base
          end
        when :word
          if tokens.last
            case tokens.last[0]
            when :flag
              tokens.last[2] = v
            else
              tokens << [:argument, v] if @base
            end
          end
        end
      end
      @argv = Tokens.to_array(pre)
      
      tokens
    end
    
  #### CREATION HELPERS #### 
    
    # Add a new switch to +@switches+
    #
    # @overload switch(short, long, desc, &block)
    #   Creates a new switch
    #   @param [Symbol] short single character for short switch, eg. +:v+ => +-v+
    #   @param [Symbol] long longer switch to be used, eg. +:verbose+ => +--verbose+
    #   @param [String] desc the description for the switch
    #
    # @yield A block to run if the switch is triggered
    #
    def switch(*args, &block)
      short, long, desc = nil
      args.each do |i|
        if i.is_a? String
          desc = i
        elsif i.length == 1
          short = i.to_s
        else
          long = i.to_s
        end
      end
      @switches << Switch.new(short, long, desc, &block)
    end
    
    # Add a new command to +@commands+
    #
    # @overload command(name, desc, &block)
    #   Creates a new command
    #   @param [Symbol] name the name of the command, eg. +:add+ for +git add+
    #   @param [String] desc description of the command
    # 
    # @yield A block to run when the command is called, can contain switches
    #   and flags
    #
    def command(*args, &block)
      name, desc = nil
      args.each do |i|
        if i.is_a? String
          desc = i
        else
          name = i
        end
      end
      @commands << Command.new(name, desc, &block)
    end
    
    # Add a new flag to +@flags+
    #
    # @overload flag(short, long, desc, &block)
    #   Creates a new flag
    #   @param [Symbol] short single character for short flag, eg. +:t+ => +-t 10+
    #   @param [Symbol] long longer switch to be used, eg. +:tries+ => +--tries=10+
    #   @param [String] desc the description for the flag
    #
    # @yield [String] A block to be run if switch is triggered
    def flag(*args, &block)
      short, long, desc, arg_name = nil
      args.each do |i|
        if i.is_a? String
          if i =~ /^[\[\]A-Z0-9]+$/
            arg_name = i
          else
            desc = i
          end
        elsif i.length == 1
          short = i.to_s
        else
          long = i.to_s
        end
      end
      @flags << Flag.new(short, long, desc, arg_name, &block)
    end
    
    # Creates a boolean switch. This is done by adding two switches of
    # Boolean type to +@switches+, one is created normally the other has
    # "no-" appended to the long name and has no short name.
    #
    # @overload boolean(short, long, desc, &block)
    #   Creates a new boolean switch
    #   @param [Symbol] short single character for short label
    #   @param [Symbol] long longer name to be used
    #   @param [String] desc the description of the boolean
    #
    # @yield [Boolean] A block to be run if switch is triggered
    def boolean(*args, &block)
      short, long, desc = nil
      args.each do |i|
        if i.is_a? String
          desc = i
        elsif i.length == 1
          short = i.to_s
        else
          long = i.to_s
        end
      end
      raise "Boolean switch must have long name" unless long
      @switches << Boolean.new(short, long, desc, true, &block)
      @switches << Boolean.new(nil, "no-#{long}", desc, false, &block)
    end
    
  #### HELP STUFF ####
    
    # This actually creates a switch with "-h" and "--help" that control
    # the help on this command. If this is the base class it will also 
    # creates a "help [command]" command.
    def build_help
      @switches << Switch.new("h", "help", "Display help") do
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
      a = @name
      b = @desc
      s, p = '', ''
      (0..width-a.length).each {s << ' '}
      (0..prepend).each {p << ' '}
      "#{p}#{a}#{s}#{b}"
    end
    
    # Generate the summary for help, show all flags and switches, but do not
    # show the flags and switches within each command. Should also prepend the
    # banner.
    def help(width=30, prepend=5)
      summary = "#{@header}\n"
      
      if @switches.length > 0 || @flags.length > 0
        summary << "\n Options:\n"
        @switches.each do |i|
          summary << i.summary(width, prepend) << "\n" if i.summary
        end
        @flags.each do |i|
          summary << i.summary(width, prepend) << "\n"
        end
      end
      
      if @commands.length > 0
        summary << "\nCommands:\n"
        @commands.each do |i|
          summary << i.summary(width, prepend) << "\n"
        end
      end
      
      summary << "\n#{@footer}\n" if @footer
     
      summary
    end
    
    
  end
end