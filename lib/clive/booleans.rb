class Clive
  
  # A switch which can be triggered with either --no-verbose or --verbose
  # for example.
  class Boolean < Switch
    attr_accessor :truth
    
    def initialize(short, long, desc, truth, &block)
      @short = short
      @long = long
      @desc = desc
      @truth = truth
      @block = block
    end
    
    def run
      @block.call(@truth)
    end
    
    # @return [String] summary for help or nil if +@truth = false+
    def summary(width=30, prepend=5)
      return nil unless @truth
      a = ""
      a << "-#{@short}" if @short
      a << ", " if @short && @long
      a << "--[no-]#{@long}" if @long
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