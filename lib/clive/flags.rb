class Clive
  
  # A switch that takes an argument, with or without an equals
  #   eg. wget --tries=10
  #       wget -t 10
  #
  class Flag < Option
    attr_accessor :arg_name, :optional
        
    # Creates a new Flag instance.
    #
    # +short+ _or_ +long+ can be omitted but not both.
    #
    # @overload flag(short, long, desc, &block)
    #   Creates a new flag
    #   @param [Symbol] short single character for short flag, eg. +:t+ => +-t 10+
    #   @param [Symbol] long longer switch to be used, eg. +:tries+ => +--tries=10+
    #   @param [String] desc the description for the flag
    #
    # @yield [String] A block to be run if switch is triggered
    #
    def initialize(*args, &block)
      @names    = []
      @optional = false
      @arg_name = "ARG"
      
      args.each do |i|
        if i.is_a? String
          if i =~ /^[\[\]A-Z0-9]+$/
            @arg_name = i
          else
            @desc = i
          end
        else
          @names << i.to_s
        end
      end
      
      if @arg_name[0] == "["
        @arg_name = @arg_name[1..@arg_name.length-2]
        @optional = true
      end

      @block = block
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