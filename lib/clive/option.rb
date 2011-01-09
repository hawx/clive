module Clive
  
  # @abstract Subclass and override {#initialize} and {#run} to create a 
  #   new Option class. {#to_h} can also be overriden to provide information
  #   when building the help.
  #
  # Option is the base class for switches, flags, commands, etc. It should be
  # used as a template for the way options (or whatever) are initialized, and
  # the other methods that may need implementing.
  #
  class Option
    attr_accessor :names, :desc, :block
    
    # Create a new Option instance. 
    #
    # For subclasses the method call should take the form:
    # +initialize(names, desc, [special args], &block)+.
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
    
    # Calls the block.
    def run
      @block.call
    end
    
    # Convert the names to strings, if name is single character appends
    # +-+, else appends +--+.
    #
    # @param bool [Boolean] whether to add [no-] to long
    #
    # @example
    #
    #   @names = ['v', 'verbose']
    #   names_to_strings
    #   #=> ['-v', '--verbose']
    #
    def names_to_strings(bool=false)
      r = []
      @names.each do |i|
        next if i.nil?
        if i.length == 1 # short
          r << "-#{i}"
        else # long
          if bool
            r << "--[no-]#{i}"
          else
            r << "--#{i}"
          end
        end
      end
      r
    end
    
    # Tries to get the short name, if not chooses lowest alphabetically.
    #
    # @return [String] name to sort by
    #
    def sort_name
      r = @names.sort[0]
      @names.each do |i|
        if i.length == 1
          r = i
        end
      end
      r
    end
    
    # Compare options based on Option#sort_name
    def <=>(other)
      self.sort_name <=> other.sort_name
    end
    
    # @return [Hash{String=>Object}]
    #   Returns a hash which can be passed to the help formatter.
    #
    def to_h
      {
        "names" => names_to_strings,
        "desc"  => @desc
      }
    end
    
    def inspect
      "#<#{self.class.name} [#{@names.join(', ')}]>"
    end
  
  end
end
