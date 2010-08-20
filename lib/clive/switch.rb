class Clive
  
  # A string that takes no argument, beginning with one or two dashes
  #   eg. ruby --version
  #       ruby -v
  #
  class Switch < Option
      
    # Create a new Switch instance.
    #
    # +short+ _or_ +long+ may be omitted but not both.
    #
    # @overload switch(short, long, desc, &block)
    #   Creates a new switch
    #   @param [Symbol] short single character for short switch, eg. +:v+ => +-v+
    #   @param [Symbol] long longer switch to be used, eg. +:verbose+ => +--verbose+
    #   @param [String] desc the description for the switch
    #
    # @yield A block to run if the switch is triggered
    #
    def initialize(*args, &block)
      @names = []
      args.each do |i|
        case i
        when Symbol
          @names << i.to_s
        when String
          @desc = i
        end
      end
      @block = block
    end
    
    # Runs the block that was given
    def run
      @block.call
    end
    
  end
end