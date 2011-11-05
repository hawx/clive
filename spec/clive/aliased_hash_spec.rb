$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::AliasedHash do
  
  subject { Clive::AliasedHash }
  
  describe '#alias' do
    it 'sets up an alias' do
      h = subject[:a => 1]
      h.alias :b, :a
      h.instance_variable_get(:@aliases).must_equal({:b => :a})
    end
    
    it 'warns of duplicate keys' do
      h = subject[:a => 1]
      this {
        h.alias :a, :b
      }.must_output nil, "Key :a already exists in {:a=>1}\n"
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
    it 'returns a hash with aliases' do
      h = subject[:a => 1]
      h.alias :b, :a
      h.to_hash.must_equal({:a => 1, :b => 1})
    end
  end
  
end