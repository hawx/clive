$: << File.dirname(__FILE__) + '/..'
require 'helper'

class HashTest < MiniTest::Unit::TestCase
  
  def test_removes_keys_given
    hsh = {:a => 1, :b => 2, :c => 3}
    assert_equal [:a], hsh.without(:b, :c).keys
  end
  
  def test_checks_for_multiple_keys
    hsh = {:a => 1, :b => 2, :c => 3}
    assert hsh.has_any_key?(:a, :d)
    refute hsh.has_any_key?(:d, :e)
  end
  
  def test_flips_hash
    hsh = {:a => [:aa, :ab, :ac], :b => [:ba]}
    assert_equal({:aa => :a, :ab => :a, :ac => :a, :ba => :b}, hsh.flip)
  end
  
  def test_renames_hash
    hsh = {:a => 1, :b => 2}
    assert_equal({:c => 1, :d => 2}, hsh.rename({:a => :c, :b => :d}))
  end
  
end

class SymbolTest < MiniTest::Unit::TestCase
  
  def test_returns_string_with_dashes
    assert_equal 'a-b-c', :a_b_c.dashify
  end

end

class StringTest < MiniTest::Unit::TestCase

  def test_returns_symbol_with_underscores
    assert_equal :a_b_c, 'a-b-c'.symbolify
  end

end