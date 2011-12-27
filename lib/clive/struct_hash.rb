class Clive

  # A Struct-like Hash (or Hash-like Struct)
  #
  #   sh = StructHash.new(:a => 1)
  #   sh.a       #=> 1
  #   sh[:a]     #=> 1
  #
  #   sh.set 42, [:answer, :life]
  #   sh.answer  #=> 42
  #   sh.life    #=> 42
  #
  #   sh.to_h 
  #   #=> {:a => 1, :answer => 42}
  #   sh.to_struct('Thing')
  #   #=> #<struct Struct::Thing @a=1 @answer=42>
  #
  class StructHash
    
    def initialize(kvs={})
      @data = kvs
      @aliases = Hash[ kvs.map {|k,v| [k, k] } ]
    end
    
    # Sets a value in the StructHash, this can be set with multiple keys but the 
    # first will be set as the most important key, the others will not show up in
    # #to_h or #to_struct.
    #
    # @param keys [#to_sym, Array<#to_sym>]
    # @param val
    def store(keys, val)
      keys = Array(keys)
      keys.map!(&:to_sym)
    
      keys.each do |key| 
        @aliases[key] = keys.first
      end
      
      @data[keys.first] = val
    end
    
    # Gets the value from the StructHash corresponding to the key given.
    #
    # @param key [Symbol]
    def [](key)
      @data[@aliases[key]]
    end
    alias_method :get, :[]
    
    # Checks whether the StructHash contains an entry for the key given.
    def key?(key)
      @aliases.key?(key)
    end
    
    # @return [Hash] The data without the +:args+ key.
    def data
      @data.reject {|k,v| k == :args }
    end
    
    # Returns a hash representation of the StructHash instance, using only the
    # important keys. This acts recursively, so any contained StructHashes
    # will have #to_h called on them.
    #
    # @return [Hash]
    def to_h
      Hash[ data.map {|k,v| v.is_a?(StructHash) ? [k, v.to_h] : [k, v] } ]
    end
    alias_method :to_hash, :to_h
    
    # Returns a struct representation of the StructHash instance, using only the
    # important keys. This does not modify any contained StructHash instances
    # like #to_h, but leaves them as they are.
    #
    # @return [Struct]
    def to_struct(name=nil)
      Struct.new(name, *data.keys).new *data.values
    end
    
    # Checks whether the method corresponds to a key, if so gets the value.
    # Checks whether the method ends with '?', then checks if the key exists.
    # Otherwise calls super.
    def method_missing(sym, *args, &block)
      if key?(sym)
        get sym
      elsif sym.to_s[-1] == "?"
        key? sym.to_s[0..-2].to_sym
      else
        super sym, *args, &block
      end
    end
    
    def ==(other)
      to_h == other.respond_to?(:to_h) ? other.to_h : other
    end
    
  end
end