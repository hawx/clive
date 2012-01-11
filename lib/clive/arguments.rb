class Clive
  # An Array of {Clive::Argument} instances.
  class Arguments < Array

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
    #   list.zip(found_args).map {|i| [i[0].to_s, i[1]] }
    #   #=> [['[<a>]', nil], ['<b>', 1], ['<c>', 2], ['[<d>]', 3]]
    #
    #
    # @param other [Array<String>] Found list of arguments.
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

    # @return [String]
    def to_s
      map {|i| i.to_s }.join(' ').gsub('] [', ' ')
    end

    # @return [Integer] The minimum number of arguments that *must* be given.
    def min
      reject {|i| i.optional? }.size
    end

    # @return [Integer] The maximum number of arguments that *can* be given.
    def max
      size
    end

    # Whether the +list+ of found arguments could possibly be the arguments for
    # this option. This does not need to check the minimum length as the list
    # may not be completely built, this just checks it hasn't failed completely.
    #
    # @param list [Array<Object>]
    def possible?(list)
      return true if list.empty?
      i = 0
      optionals = []

      list.each do |item|
        break if i >= size

        # Either, +item+ is self[i]
        if self[i].possible?(item)
          i += 1

        # Or, the argument is optional and there is another argument to move to
        # meaning it can be skipped
        elsif self[i].optional? && (i < size - 1)
          i += 1
          optionals << item

        # Or, an optional argument has been skipped and this could be it so bring
        # it back from the dead and check, if it is remove it and move on
        elsif optionals.size > 0 && self[i].possible?(optionals.first)
          i += 1
          optionals.shift

        # Problem
        else
          return false
        end
      end

      list.size <= max
    end

    # Whether the +list+ of found arguments is valid to be the arguments for this
    # option. Here length is checked as we need to make sure enough arguments are
    # present.
    #
    # It is important that when the arguments are put in the correct place
    # that we check for missing arguments (which have been added as +nil+s)
    # so compact the list _then_ check the size.
    #
    # @param list [Array<Object>]
    def valid?(list)
      zip(list).map do |a,i|
        if a.optional?
          nil
        else
          i
        end
      end.compact.size >= min && possible?(list)
    end

    # Will fill spaces in +list+ with default values, then coerces all arguments
    # to the corect types.
    #
    # @return [Array]
    def create_valid(list)
      zip(list).map {|a,r| r ? a.coerce(r) : a.coerce(a.default) }
    end

  end
end
