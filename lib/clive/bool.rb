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
    # @param names [Array[Symbol]]
    #   Names that the boolean switch can be called with, must include
    #   a long name (eg. 2 or more characters) so that the --no- can
    #   be prefixed.
    #
    # @param desc [String]
    #   A description of the bool.
    #
    # @param truth [true, false] 
    #   Truth of the switch to create.
    #
    # @yield [true, false] A block to be run when the switch is triggered
    # @raise [MissingLongName] Raised when a long name is not given
    #
    def initialize(names, desc, truth, &block)
      @names = []
      names.each do |i|
        if truth
          @names << i.to_s
        else
          @names << "no-#{i.to_s}" if i.length > 1
        end
      end
      
      # booleans require a long name to add --no- to
      unless @names.find_all {|i| i.length > 1}.length > 0
        raise MissingLongName, @names[0]
      end
      
      @desc = desc
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
      if @truth
        {'names' => names_to_strings(true), 'desc' => @desc}
      else
        nil
      end
    end
  
  end
end