module Clive
  
  # A string that takes no argument, beginning with one or two dashes
  #   eg. ruby --version
  #       ruby -v
  #
  class Switch < Option
      
    # Create a new Switch instance.
    #
    # @param names [Array[Symbol]]
    #   An array of names the option can be invoked by.
    #
    # @param desc [String]
    #   A description of what the option does.
    #
    # @yield A block to run if the switch is triggered
    #
    def initialize(names, desc, &block)
      @names = names.map(&:to_s)
      @desc  = desc
      @block = block
    end
    
    # Runs the block that was given
    def run
      @block.call
    end
    
  end
end