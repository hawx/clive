module Clive
  class Option
  
    # An Array of {Argument} instances.
    class ArgumentList < Array
      
      alias_method :_zip, :zip
      
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
      #   # The map at the end just makes it easier to read you will want to
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

      def to_s
        map {|i| i.to_s }.join(' ').gsub('] [', ' ')
      end
    end
  
  end
end