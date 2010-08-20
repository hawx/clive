class Clive
  
  class Option
    attr_accessor :names, :desc, :block
    
    def initialize(desc, *names, &block)
      @names = names
      @desc = desc
      @block = block
    end
    
    def run
      @block.call
    end
    
    def summary(width=30, prepend=5)
      n = names_to_strings.join(', ')
      spaces = width-n.length
      spaces = 1 if spaces < 1
      s = spaces(spaces)
      p = spaces(prepend)
      "#{p}#{n}#{s}#{@desc}"
    end
    
    # Convert the names to strings, depending on length
    #
    # @param [Boolean] bool whether to add [no-] to long
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
    
    # Create a string of +n+ spaces
    def spaces(n)
      s = ''
      (0...n).each {s << ' '}
      s
    end
    
    # Tries to get the short name, if not choose lowest alphabetically
    #
    # @return [String] name to sort by
    def sort_name
      r = @names.sort[0]
      @names.each do |i|
        if i.length == 1
          r = i
        end
      end
      r
    end
    
    def <=>(other)
      self.sort_name <=> other.sort_name
    end
  
  end
end
