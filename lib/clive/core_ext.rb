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
  
  # @example
  #
  #   {:a => 1, :b => 2}.rename(:a => :c, :b => :d)
  #   #=> {:c => 1, :d => 2}
  #
  def rename(new_names)
    Hash[ map {|k,v| [new_names[k], v] } ]
  end
  
end


class Array
  
  # @example
  #
  #   [1, 2, 3].zip_to_pattern(%w(a c), [true, false, true])
  #   #=> [[1, 'a'], [2, nil], [3, 'c']]
  #
  def zip_to_pattern(other, pattern)
    other = other.dup
    diff = other.size - pattern.find_all {|i| i == true }.size
    
    result = dup.map {|i| [i, nil] }
    pattern.each_index do |i|
      curr = pattern[i]
      if curr
        result[i][1]= other.shift
      elsif diff > 0
        diff -= 1
        result[i][1] = other.shift
      end
    end
    
    result
  end
  
  # @example
  #  
  #   arr = [:a, :bb, :ccc]
  #   other = [1, 3]
  #   conds = [-> a,b { a.size == b}] * 3
  #
  #   arr.zip_with_conditions(other, conds)
  #   #=> [[:a, 1], [:bb, nil], [:ccc, 3]]
  #
  def zip_with_conditions(other, conditions)
    other = other.dup
    r = []
    
    # count the number of trues we will get
    _other = other.dup
    trues = 0
    zip(conditions).each do |a, cond|
      _other.each do |o|
        if cond.call(a, o)
          trues += 1
          _other.shift
          break
        end
      end
    end
    
    # how many can we add that are false?
    diff = other.size - trues
    
    zip(conditions).each do |a, cond|
      if cond.call(a, other.first)
        r << other.shift
      elsif diff > 0
        diff -= 1
        r << other.shift
      else
        r << nil
      end
    end
    
    zip(r)
  end
  
end

class Symbol

  # A valid Symbol can not contain dashes, so instead underscores are used,
  # this method returns a String with all underscores changed to dashes.
  #
  # @example
  #   :a_b_c.dashify #=> 'a-b-c'
  #
  # @see String#symbolify
  # @return [String]
  def dashify
    to_s.gsub('_', '-')
  end
end

class String

  # The string will probably contain dashes as they look nicer, but to be a 
  # Symbol these must be removed and replaced with underscores.
  #
  # @example
  #   'a-b-c'.symbolify #=> :a_b_c
  #
  # @see Symbol#dashify
  # @return [Symbol]
  def symbolify
    gsub('-', '_').to_sym
  end
end
