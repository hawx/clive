class Clive
  
  # Helper module to include to gain access to a #command method.
  # This assumes +@commands+ is available.
  module CommandHelper
  
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
      name, desc = nil, nil
      args.each do |i|
        if i.is_a? String
          desc = i
        else
          name = i
        end
      end
      @commands << Command.new(name, desc, &block)
    end
  end
  
  class Commands < Array
    
    # If passed a Symbol or String will get the command with that name. 
    # Otherwise does what you expect of an Array (see Array#[])
    #
    # @param [Symbol, String, Integer] name or index of item to return
    # @return [Command] the command which has been found
    def [](val)
      val = val.to_s if val.is_a? Symbol
      if val.is_a? String
        self.find_all {|i| i.name == val}[0]
      elsif val.is_a? Integer
        super
      end
    end
    
  end
  
  # A string which describes the command to execute
  #   eg. the add in git add
  # or the main base that holds all other commands, switches
  # and flags
  class Command
    
    attr_accessor :switches, :flags, :commands
    attr_accessor :name, :desc, :block, :argv
    attr_accessor :base
    
    # Create a new CommandUnit instance
    #
    # @overload initialize(base, &block)
    #   Creates a new base CommandUnit to house everything else
    #   @param [Boolean] base whether the command is the base
    #
    # @overload initialize(name, desc, &block)
    #   Creates a new CommandUnit as part of the base CommandUnit
    #   @param [Symbol] name the name of the command
    #   @param [String] desc the description of the command
    #
    # @yield A block to run, containing switches and flags
    #
    def initialize(*args, &block)
      @argv = []
      @switches = Switches.new
      @flags = Flags.new
      @commands = Commands.new
    
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
    end
    
    include SwitchHelper
    include FlagHelper
    include CommandHelper
    
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
    def run(argv)
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
    # @param [Array] the command line input
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
      pre = pre_tokens(argv)
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
        tokens << [:command, command, command.tokenize(arg_tokens(pre))]
        pre = pre_tokens(command.argv)
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
            raise "error, flag/switch '#{v}' does not exist" if @base
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
      @argv = arg_tokens(pre)
      
      tokens
    end
    
    # Turn into simple tokens that have been split up into logical parts
    #
    # @example
    #
    #   c.pre_tokens(["add", "-al", "--verbose"])
    #   #=> [[:word, "add"], [:short, "a"], [:short, "l"], [:long, "verbose"]]
    def pre_tokens(arg)
      tokens = []
      arg.each do |i|
        if i[0..1] == "--"
          if i.include?('=')
            a, b = i[2..i.length].split('=')
            tokens << [:long, a] << [:word, b]
          else
            tokens << [:long, i[2..i.length]]
          end
        elsif i[0] == "-"
          i[1..i.length].split('').each do |j|
            tokens << [:short, j]
          end
        else
          tokens << [:word, i]
        end
      end
      tokens
    end
    
    # Convert pre_tokens into argv style array
    def arg_tokens(tokens)
      argv = []
      tokens.each do |i|
        k, v = i[0], i[1]
        case k
        when :long
          argv << "--#{v}"
        when :short
          argv << "-#{v}"
        when :word
          argv << v
        end
      end
      
      argv
    end

  end

end