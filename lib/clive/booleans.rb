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
    
    #def short
    #  @names[0]
    #end
    #def long
    #  @names[1]
    #end
    
    # Run the block with +@truth+
    def run
      @block.call(@truth)
    end
    
    # @return [String] summary for help or nil if +@truth = false+
    def summary(width=30, prepend=5)
      return nil unless @truth
      
      n = names_to_strings(true).join(', ')
      spaces = width-n.length
      spaces = 1 if spaces < 1
      s = spaces(spaces)
      p = spaces(prepend)
      "#{p}#{n}#{s}#{@desc}"
    end
  
  end
end