class Clive
  
  # Helper module to include to gain access to a #flag method.
  # This assumes +@flags+ is available.
  module FlagHelper
  
    # Add a new flag to +@flags+
    #
    # @overload flag(short, long, desc, &block)
    #   Creates a new flag
    #   @param [Symbol] short single character for short flag, eg. NEED EXAMPLE
    #   @param [Symbol] long longer switch to be used, eg. NEED EXAMPLE
    #   @param [String] desc the description for the flag
    #
    # @yield [String] A block to be run if switch is triggered
    def flag(*args, &block)
      short, long, desc = nil, nil, nil
      args.each do |i|
        if i.is_a? String
          desc = i
        elsif i.length == 1
          short = i.to_s
        else
          long = i.to_s
        end
      end
      @flags << Flag.new(short, long, desc, &block)
    end
  end

  class Flags < Switches
  end
  
  # A switch that takes an argument
  #   eg. git merge -s resolve
  #       git merge --strategy=resolve
  class Flag < Switch
  
    # Runs the block that was given with an argument
    #
    # @param [String] arg argument to pass to the block
    def run(arg)
      @block.call(arg)
    end
    
  end
end