class Clive
  
  # A switch which can be triggered with either --no-verbose or --verbose
  # for example.
  class Boolean < Option
    attr_accessor :truth
    
    # Create a new Boolean instance
    #
    # @param [String] short the short way of calling the boolean
    # @param [String] long the long way of calling the boolean
    # @param [String] desc the description of the boolean
    # @param [Proc] block the block to call when the boolean is called
    #
    def initialize(short, long, desc, truth, &block)
      @names = [short, long]
      @desc = desc
      @truth = truth
      @block = block
    end
    
    def short
      @names[0]
    end
    def long
      @names[1]
    end
    
    # Run the block with +@truth+
    def run
      @block.call(@truth)
    end
    
    # @return [String] summary for help or nil if +@truth = false+
    def summary(width=30, prepend=5)
      return nil unless @truth
      
      a = ""
      a << "-#{short}" if short
      a << ", " if short && long
      a << "--[no-]#{long}" if long
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