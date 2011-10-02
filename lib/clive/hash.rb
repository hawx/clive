module Clive

  class Hash < ::Hash
    
    # @return [Hash] A new hash without the keys (and obviously related values)
    #  specified.
    #
    # @example
    #
    #   {:a => 1, :b => 2, :c => 3}.without(:a, :c)
    #   #=> {:b => 2}
    #
    def without(*keys)
      reject {|k,v| keys.include?(k) } 
    end
    
    # Like #has_key? but can pass multiple keys to check.
    def has_any_key?(*keys)
      keys.any? {|key| has_key?(key) }
    end
    
    # Like #has_key? but checks for all keys.
    def has_all_keys?(*keys)
      keys.all? {|key| has_key?(key) }
    end
    
    # Given a hash with symbol keys pointing to array values, a new hash is built 
    # with each value in the array pointing to the key.
    #
    # @example
    #
    #   {:a => [:b, :c], :d => [:e, :f]}.flip
    #   #=> {:b => :a, :c => :a, :e => :d, :f => :d}
    #
    def flip
      res = {}
      each do |k, v|
        v.each do |i|
          res[i] = k
        end
      end
      res
    end
    
    # Renames the hash keys based on +new_names+, additionally if a key is present
    # in the hash but not in +new_names+ the key (and value) are removed.
    # 
    # @example
    #
    #   {:a => 1, :b => 2, :c => 3}.rename(:a => :c, :b => :d)
    #   #=> {:c => 1, :d => 2}
    #
    #   {:a => 1, :b => 3}.rename([:a])  # same as .rename({:a => :a})
    #   #=> {:a => 1}
    #
    def rename(new_names)
      inject({}) do |hsh, (k,v)|
        if new_names.include?(k)
          if new_names.respond_to?(:key?)
            hsh[new_names[k]] = v
          else
            hsh[k] = v
          end
        end
        hsh
      end
    end
    
  end
end
