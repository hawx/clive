class Clive
  
  # A switch which can be triggered with either --no-verbose or --verbose
  # for example.
  class Boolean < Option
    attr_accessor :truth
    
    class NoLongName < CliveError
      def reason; "missing long name"; end
    end
    
    # Creates a new Boolean switch instance. A boolean switch has a truth, 
    # this determines what is passed to the block. They should be created 
    # in pairs so one can be +--something+ the other +--no-something+.
    #
    # +short+ and/or +desc+ can be omitted when creating a Boolean, all
    # other arguments must be present.
    #
    # @overload initialize(short, long, desc, truth, &block)
    #   Creates a new boolean switch
    #   @param [Symbol] short single character to use
    #   @param [Symbol] long word/longer name for boolean switch
    #   @param [String] desc description of use/purpose
    #
    # @yield [Boolean] A block to be run when the switch is triggered
    #
    def initialize(*args, truth, &block)
      @names = []
      args.each do |i|
        case i
        when Symbol
          if truth
            @names << i.to_s
          else
            @names << "no-#{i.to_s}" if i.length > 1
          end
        when String
          @desc = i
        end
      end
      
      unless @names.find_all {|i| i.length > 1}.length > 0
        raise NoLongName, @names[0]
      end
      
      @truth = truth
      @block = block
    end
    
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