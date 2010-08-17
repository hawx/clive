class Clive

  # A subclass of Array to allow the creation of arrays that look
  # like:
  #
  #    [[:word, 'Value'], [:long, 'verbose'], [:short, 'r']]
  #
  # The tokens are not stored like that but as the string 
  # representations:
  #
  #   ["Value", "--verbose", "-r"]
  #
  class Tokens < Array
      
    TOKEN_KEYS = [:word, :short, :long]
    
    # Create a new Tokens instance. Pass either an array of tokens
    # or a plain array, they will be converted correctly.
    #
    # @param [Array]
    # @return [Tokens]
    #
    def initialize(args=[])
      if token?(args[0])
        r = []
        args.each {|i| r << token_to_string(i)}
        args = r
      end
      super(args)
    end
    
    # Turn +@tokens+ into an array, this ensures that shorts are split
    # as is expected
    #
    # @return [Array] array representation of tokens held
    def array
      return [] unless self.tokens
      arr = []
      self.tokens.each do |i|
        k, v = i[0], i[1]
        case k
        when :long
          arr << "--#{v}"
        when :short
          arr << "-#{v}"
        when :word
          arr << v
        end
      end
      
      arr
    end
    
    # Creates an array of tokens based on +self+
    #
    # @return [Array] the tokens that are held
    def tokens
      t = []
      self.each do |i|
        if i[0..1] == "--"
          if i.include?('=')
            a, b = i[2..i.length].split('=')
            t << [:long, a] << [:word, b]
          else
            t << [:long, i[2..i.length]]
          end
          
        elsif i[0] == "-"
          i[1..i.length].split('').each do |j|
            t << [:short, j]
          end
        
        else
          t << [:word, i]
        end
      end
      
      t
    end
    
    def self.to_tokens(arr)
      Tokens.new(arr).tokens
    end
    
    def self.to_array(tokens)
      Tokens.new(tokens).array
    end
    
    # Checks to see if it is a token being added and changes it back
    def <<(val)
      if token?(val)
        super(token_to_string(val))
      else
        super
      end
    end
    
    # Test whether an array is a token
    #
    # @param [Array]
    # @return [Boolean]
    #
    # @example
    #  
    #   t.token?([:word, "something"]) #=> true
    #   t.token?(["a", "normal", "array"]) #=> false
    #
    def token?(arr)
      return false if arr.nil?
      TOKEN_KEYS.include?(arr[0])
    end
    
    # Convert a tokens to its string representation
    def token_to_string(token)
      k, v = token[0], token[1]
      case k
      when :long
        "--#{v}"
      when :short
        "-#{v}"
      when :word
        v
      end
    end
    
    # This is here to force the use of #tokens and #array when 
    # accessing the contents
    def inspect
      "#<Clive::Tokens:0x#{'%x' % (self.object_id << 1)} #{self.tokens}>"
    end
    
  end
end
