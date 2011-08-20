class Hash
  
  # @return [Hash] A new hash without the keys (and obviously related values)
  #  specified.
  def without(*keys)
    reject {|k,v| keys.include?(k) } 
  end
  
  # Like #has_key? but can pass multiple keys to check.
  def has_any_key?(*keys)
    keys.any? {|key| has_key?(key) }
  end
  
  # Given a hash with symbol keys pointing to array values, a new hash is built 
  # with each value in the array pointing to the key.
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