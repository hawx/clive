class Clive
  
  # A switch that takes an argument, with or without an equals
  #   eg. wget --tries=10
  #       wget -t 10
  #
  class Flag
    attr_accessor :short, :long, :desc, :block
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
      @short = short
      @long = long
      @desc = desc
      
      if arg_name && arg_name[0] == "["
        @arg_name = arg_name[1..arg_name.length-2]
        @optional = true
      else
        @arg_name = arg_name
        @optional = false
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
      a = ""
      a << "-#{@short}" if @short
      a << ", " if @short && @long
      a << "--#{@long}" if @long
      a << " #{@arg_name}" if @long unless @optional
      a << " [#{@arg_name}]" if @long && @optional
      b = @desc
      s, p = '', ''
      # want at least one space between name and desc
      spaces = width-a.length < 0 ? 1 : width-a.length
      (0...spaces).each {s << ' '}
      (0...prepend).each {p << ' '}
      "#{p}#{a}#{s}#{b}"
    end
    
  end
end