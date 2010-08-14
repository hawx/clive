class Clive
  
  # A string that takes no argument, beginning with one or two dashes
  #   eg. ruby --version
  #       ruby -v
  #
  class Switch
    attr_accessor :short, :long, :desc, :block
    
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
      (0..width-a.length).each {s << ' '}
      (0..prepend).each {p << ' '}
      "#{p}#{a}#{s}#{b}"
    end
    
  end
  
end