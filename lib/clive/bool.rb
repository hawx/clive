module Clive

  # A switch which can be triggered with either --no-[name] and --[name].
  # The 'truth' of this is then passed to the block.
  #
  class Bool < Option
    attr_accessor :truth
    
    # Creates a new Bool switch instance. A boolean switch has a truth, 
    # this determines what is passed to the block. They should be created 
    # in pairs so one can be +--something+ the other +--no-something+.
    # NOTE: this does not happen within this class!
    #
    # +short+ and/or +desc+ can be omitted when creating a Boolean, all
    # other arguments must be present.
    #
    # @overload initialize(short, long, desc, truth, &block)
    #   Creates a new boolean switch
    #   @param short [Symbol] single character to use
    #   @param long [Symbol] word/longer name for boolean switch
    #   @param desc [String] description of use/purpose
    #   @param truth [Boolean] truth of switch to create
    #
    # @yield [Boolean] A block to be run when the switch is triggered
    # @raise [MissingLongName] raises when a long name is not given
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
      
      # booleans require a long name to add --no- to
      unless @names.find_all {|i| i.length > 1}.length > 0
        raise MissingLongName, @names[0]
      end
      
      @truth = truth
      @block = block
    end
    
    # Run the block with the switches truth.
    def run
      @block.call(@truth)
    end
    
    # Should only return a hash when this is the 'true' switch.
    # @see Clive::Option#to_h
    def to_h
      return nil unless @truth
      
      {
        'names' => names_to_strings(true),
        'desc' => @desc
      }
    end
  
  end
end