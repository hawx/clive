class Hash
  
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
end