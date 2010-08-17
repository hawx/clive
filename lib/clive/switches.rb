class Clive
  
  # A string that takes no argument, beginning with one or two dashes
  #   eg. ruby --version
  #       ruby -v
  #
  class Switch
    attr_accessor :short, :long, :desc, :block
    
    # Create a new Switch instance
    #
    # @param [String] short the short way of calling the switch
    # @param [String] long the long way of calling the switch
    # @param [String] desc the description of the switch
    # @param [Proc] block the block to call when the switch is called
    #
    def initialize(short, long, desc, &block)
      @short = short
      @long = long
      @desc = desc
      @block = block
    end
    
    # Runs the block that was given
    def run
      @block.call
    end
    
    # @return [String] summary for help
    def summary(width=30, prepend=5)
      a = ""
      a << "-#{@short}" if @short
      a << ", " if @short && @long
      a << "--#{@long}" if @long
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