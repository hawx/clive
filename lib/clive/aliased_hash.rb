module Clive

  # @example
  #   
  #   h = AliasedHash.new
  #   h[:verbose] = true
  #   h.alias :v, :verbose
  #   
  #   h[:v] == h[:verbose]
  #   #=> true
  #
  #   h.to_hash
  #   #=> {:verbose => true, :v => true}
  #
  class AliasedHash < Hash
  
    # Creates a new alias, that is a key which when accessed points
    # to the value of a different key. It never has a value in the
    # usual sense.
    #
    # @param to New key name
    # @param from Key which will be "pointed" to
    # 
    # @example
    #
    #   h = AliasedHash.new
    #   h[:a] = 1
    #   h.alias :b, :a
    #   h[:b] #=> 1
    #
    def alias(to, from)
      if has_key?(to)
        warn "Key #{to.inspect} already exists in #{inspect}, this will overwrite it."
      end
      
      @aliases ||= {}
      @aliases[to] = from
    end

    # @return Whether the alias +key+ exists
    def alias?(key)
      @aliases != nil && @aliases.has_key?(key)
    end
    alias_method :has_alias?, :alias?
    
    # Retrieves the value object corresponding to the key given, if key
    # refers to an alias the value referred to by that is returned.
    def [](key)
      if alias?(key)
        super @aliases[key]
      else
        super
      end
    end
    
    # Sets the value for the key given, if key refers to an alias the value
    # will be set on the key it refers to.
    def []=(key, val)
      if alias?(key)
        super @aliases[key], val
      else
        super key, val
      end
    end
    
    # @return [Hash]
    def to_hash
      r = Hash[super]
      @aliases.each {|k,v| r[k] = r[v] }
      r
    end
    
  end
end