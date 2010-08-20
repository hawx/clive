class Clive
  
  # A switch that takes an argument, with or without an equals
  #   eg. wget --tries=10
  #       wget -t 10
  #
  class Flag < Option
    attr_accessor :arg_name, :optional
    
    # Create a new Flag instance
    #
    # @param [String] short the short way of calling the flag
    # @param [String] long the long way of calling the flag
    # @param [String] desc the description of the flag
    # @param [String] arg_name the name of the argument given to the flag
    # @param [Proc] block the block to call when the flag is called
    #
    def initialize(short, long, desc, arg_name, &block)
      @names = [short, long]
      @desc = desc
      
      if arg_name && arg_name[0] == "["
        @arg_name = arg_name[1..arg_name.length-2]
        @optional = true
      else
        @arg_name = arg_name || "ARG"
        @optional = false
      end
      @block = block
    end
    
    def short
      @names[0]
    end
    def long
      @names[1]
    end
    
    # Runs the block that was given with an argument
    #
    # @param [String] arg argument to pass to the block
    def run(arg)
      @block.call(arg)
    end
    
    # @return [String] summary for help
    def summary(width=30, prepend=5)
      n = names_to_strings.join(', ')
      if @optional
        n << " [#{@arg_name}]"
      else
        n << " #{@arg_name}"
      end
      
      spaces = width-n.length
      spaces = 1 if spaces < 1
      s = spaces(spaces)
      p = spaces(prepend)
      "#{p}#{n}#{s}#{@desc}"
    end
    
  end
end