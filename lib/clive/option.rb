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
    # @example
    #
    #   @names = ['v', 'verbose']
    #   names_to_strings
    #   #=> ['-v', '--verbose']
    #
    def names_to_strings
      r = []
      @names.each do |i|
        next if i.nil?
        if i.length == 1 # short
          r << "-#{i}"
        else # long
          r << "--#{i}"
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
  
  end
end
