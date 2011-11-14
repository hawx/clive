$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::AliasedHash do
  
  subject { Clive::AliasedHash }
  
  describe '#alias' do
    it 'sets up an alias' do
      h = subject[:a => 1]
      h.alias :b, :a
      h.instance_variable_get(:@aliases).must_equal :b => :a
    end
    
    it 'warns of duplicate keys' do
      h = subject[:a => 1]
      this {
        h.alias :a, :b
      }.must_output nil, "Key :a already exists in {:a=>1}, this will overwrite it.\n"
    end
  end
  
  describe '#[]' do
    it 'allows normal access' do
      h = subject[:a => 1]
      h[:a].must_equal 1
    end
    
    it 'allows access with aliases' do
      h = subject[:a => 1]
      h.alias :b, :a
      h[:b].must_equal 1
    end
  end
  
  describe '#[]=' do
    it 'allows normal access' do
      h = subject[:a => 1]
      h[:a] = 2
      h[:a].must_equal 2
    end
    
    it 'allows access with aliases' do
      h = subject[:a => 1]
      h.alias :b, :a
      h[:b] = 2
      h[:a].must_equal 2
    end
  end
  
  describe '#to_hash' do
    it 'returns a hash without aliases' do
      h = subject[:a => 1]
      h.alias :b, :a
      h.to_hash.must_equal :a => 1
    end
  end
  
  describe '#to_expanded_hash' do
    it 'returns a hash with aliases' do
      h = subject[:a => 1]
      h.alias :b, :a
      h.to_expanded_hash.must_equal :a => 1, :b => 1
    end
  end
  
  describe '#aliases' do
    it 'returns the aliases hash' do
      h = subject[:a => 1]
      h.alias :b, :a
      h.aliases.must_equal :b => :a
    end
  end
  
  describe '#==' do
    it 'is equal to a hash with no alias references' do
      h = subject[:a => 1]
      o = {:a => 1}
      h.must_be :==, o
    end
    
    it 'is equal to a hash with alias references' do
      h = subject[:a => 1]
      h.alias :b, :a
      o = {:b => 1}
      h.must_be :==, o
    end
    
    it 'is equal with a mixture' do
      h = subject[:a => 1, :x => 2]
      h.alias :b, :a
      o = {:b => 1, :x => 2}
      h.must_be :==, o
    end
  end
  
end