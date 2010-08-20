class Clive
  
  # A string that takes no argument, beginning with one or two dashes
  #   eg. ruby --version
  #       ruby -v
  #
  class Switch < Option
      
    # Create a new Switch instance
    #
    # @param [String] short the short way of calling the switch
    # @param [String] long the long way of calling the switch
    # @param [String] desc the description of the switch
    # @param [Proc] block the block to call when the switch is called
    #
    def initialize(short, long, desc, &block)
      @names = [short, long]
      @desc = desc
      @block = block
    end
    
    # Runs the block that was given
    def run
      @block.call
    end
    
  end
end