class Clive

  # A subclass of Array to allow the creation of arrays that look
  # like:
  #
  #    [[:word, 'Value'], [:long, 'verbose'], [:short, 'r']]
  #
  # And converting between these and ordinary arrays.
  #
  class Tokens < Array
    attr_accessor :tokens, :array
    
    def self.to_tokens(tokens)
      Tokens.new.to_tokens(tokens)
    end
    
    def self.to_array(arr)
      Tokens.new.to_array(arr)
    end
    
    # Turn into simple tokens that have been split up into logical parts
    #
    # @example
    #   
    #   a = Tokens.new
    #   a.to_tokens(["add", "-al", "--verbose"])
    #   #=> [[:word, "add"], [:short, "a"], [:short, "l"], [:long, "verbose"]]
    #
    def to_tokens(arr=@array)
      @tokens = []
      arr.each do |i|
        if i[0..1] == "--"
          if i.include?('=')
            a, b = i[2..i.length].split('=')
            @tokens << [:long, a] << [:word, b]
          else
            @tokens << [:long, i[2..i.length]]
          end
        
        elsif i[0] == "-"
          i[1..i.length].split('').each do |j|
            tokens << [:short, j]
          end
        
        else
          @tokens << [:word, i]
        end
      end
      
      @tokens
    end
    
    # Turn tokens back to a normal array
    #
    # @example
    #   
    #   a = Tokens.new
    #   a.to_array([[:word, "add"], [:short, "a"], [:short, "l"],
    #              [:long, "verbose"]])
    #   #=> ["add", "-al", "--verbose"]
    #
    def to_array(tokens=@tokens)
      @array = []
      tokens.each do |i|
        k, v = i[0], i[1]
        case k
        when :long
          @array << "--#{v}"
        when :short
          @array << "-#{v}"
        when :word
          @array << v
        end
      end
      
      @array
    end
    
  end
end
