module Clive
  # An Array of {Clive::Argument} instances.
  class Arguments < Array
  
    # @todo Move some code around. Could probably move a lot of ArugmentParser into 
    #  here, then just give that the task of splitting, and normalising key names?
    #
    # @example
    #
    #   ArgumentList.create :args => '<a> [<b>]', :as => [Integer, String]
    #   #=> #<ArgumentList ...>
    #
    def self.create(opts)
      new Parser.new(opts).to_args
    end
    
    # Zips a list of found arguments to this ArgumentList, but it also takes
    # account of whether the found argument is possible and makes sure that
    # optional Arguments are correctly handled.
    # 
    # @example
    #
    #   a = Argument.new(:a, type: Integer, constraint: :even?, optional: true)
    #   b = Argument.new(:b, type: Integer, constraint: :odd?)
    #   c = Argument.new(:c, type: Integer, constraint: :even?)
    #   d = Argument.new(:d, type: Integer, constraint: :odd?, optional: true)
    #
    #   list = ArgumentList.new([a, b, c, d])
    #   found_args = %w(1 2 3)
    #
    #   # The map at the end just makes it easier to read, you will want to
    #   # omit it in real usage.
    #   list.zip(found_args).map {|i| [i[0].to_s, i[1]] }
    #   #=> [['[<a>]', nil], ['<b>', 1], ['<c>', 2], ['[<d>]', 3]]
    #   
    #
    # @param [Array<String>] Found list of arguments.
    # @return [Array<Argument,String>]
    #
    def zip(other)
      other = other.dup.compact
      # Find the number of 'spares'
      diff = other.size - find_all {|i| !i.optional? }.size
      r = []
      
      map do |arg|
        if arg.possible?(other.first)
          if arg.optional?
            if diff > 0
              [arg, other.shift]
            else
              [arg, nil]
            end
          else
            [arg, other.shift]
          end
        else
          [arg, nil]
        end
      end
    end
  
    # @return Pretty string of arguments joined with superfluous square 
    #  brackets removed.
    def to_s
      map {|i| i.to_s }.join(' ').gsub('] [', ' ')
    end
    
    # @return [Integer] The minimum number of arguments that __must__ be given.
    def min
      reject {|i| i.optional? }.size
    end
    
    # @return [Integer] The maximum number of arguments that can be given.
    def max
      size
    end
    
    # Whether the +list+ of found arguments could possibly be the arguments for
    # this option. This does not need to check the minimum length as the list
    # may not be completely built, this just checks it hasn't failed completely.
    def possible?(list)
      zip(list).all? do |arg, item|
        item ? arg.possible?(item) : true 
      end && list.size <= max
    end
    
    # Whether the +list+ of found arguments is valid to be the arguments for this
    # option. Here length is checked as we need to make sure enough arguments are
    # present.
    #
    # It is important that when the arguments are put in the correct place
    # that we check for missing arguments (which have been added as +nil+s)
    # so compact the list _then_ check the size.
    def valid?(list)
      zip(list).map do |a,i| 
        if a.optional?
          nil
        else
          i
        end
      end.compact.size >= min && possible?(list)
    end
    
    # Given +list+, will fill blank spaces with +nil+ where appropriate then
    # coerces each argument and uses default values if necessary.
    def create_valid(list)
      zip(list).map {|a,r| r ? a.coerce(r) : a.coerce(a.default) }
    end
    
  end
end