$: << File.dirname(__FILE__) + '/..'
require 'helper'

class HashTest < MiniTest::Unit::TestCase
  
  def test_removes_keys_given
    hsh = Clive::Hash[{:a => 1, :b => 2, :c => 3}]
    assert_equal [:a], hsh.without(:b, :c).keys
  end
  
  def test_checks_for_multiple_keys
    hsh = Clive::Hash[{:a => 1, :b => 2, :c => 3}]
    assert hsh.has_any_key?(:a, :d)
    refute hsh.has_any_key?(:d, :e)
  end
  
  def test_flips_hash
    hsh = Clive::Hash[{:a => [:aa, :ab, :ac], :b => [:ba]}]
    assert_equal({:aa => :a, :ab => :a, :ac => :a, :ba => :b}, hsh.flip)
  end
  
  def test_renames_hash
    hsh = Clive::Hash[{:a => 1, :b => 2}]
    assert_equal({:c => 1, :d => 2}, hsh.rename({:a => :c, :b => :d}))
  end
  
  def test_removes_unmapped_keys
    hsh = Clive::Hash[{:a => 1, :b => 2}]
    assert_equal({:c => 1}, hsh.rename({:a => :c}))
  end
  
  def test_keeps_keys_in_array
    hsh = Clive::Hash[{:a => 1, :b => 2}]
    assert_equal({:a => 1}, hsh.rename([:a]))
  end
  
end

