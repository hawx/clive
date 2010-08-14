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
    
  end
  
end