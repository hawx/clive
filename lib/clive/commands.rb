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
      else
        super
      end
    end
    
  end
  
  # A string which describes the command to execute
  #   eg. the add in git add
  class Command
    attr_accessor :name, :desc, :block, :argv
    attr_accessor :switches, :flags, :commands
    
    def initialize(name, desc, &block)
      @name = name.to_s
      @desc = desc
      @argv = []
      
      @switches = Switches.new
      @flags = Flags.new
      @commands = Commands.new
      @block = block  
    end
    
    include SwitchHelper
    include FlagHelper
    include CommandHelper
    
    # Loops through the tokens that the command calls, and calls each 
    # in turn.
    #
    # @param [Array] tokens tokens that relate to this command
    def run(tokens)
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
          # nothing
        end
      end
    end
    
    # Run the block that was given to look for switches, flags, etc.
    def parse
      self.instance_eval(&@block)
    end
    
    def tokens(arg)
      tokens = []
      @argv = arg
      arg.each do |i|
        k, v = i[0], i[1]
        case k
        when :short, :long
          if switch = @switches[v]
            tokens << [:switch, switch]
            @argv -= [[k, v]]
          elsif flag = @flags[v]
            tokens << [:flag, flag]
            @argv -= [[k, v]]
          else
            # ignore, could be part of main call
          end
        when :word
          case tokens.last[0]
          when :flag
            tokens.last[2] = v
          else
            # ignore
          end
        end
      end
      tokens
    end
    
  end

end