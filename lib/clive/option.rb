module Clive
  
  # @abstract Subclass and override {#initialize} and {#run} to create a new Option class.
  class Option
    attr_accessor :names, :desc, :block
    
    def initialize(*args, &block)
      # assign name and description
      # @block = block
    end
    
    def run
      # call the block!
      # @block.call
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
    
    # The number of arguments this option requires
    def args_size
      0
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
  
  end
end
