$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Argument::AlwaysTrue do
  subject { Clive::Argument::AlwaysTrue } 
  
  it 'is always true for the method given' do
    subject.for(:hey).hey.must_be_true
  end
  
  it 'is always true for the methods given' do
    a = subject.for(:one, :two, :three)
    a.one.must_be_true
    a.two.must_be_true
    a.three.must_be_true
  end
end

describe Clive::Argument do
  subject { Clive::Argument }
  
  describe '#initialize' do
    it 'converts name to Symbol' do
      subject.new('arg').name.must_be_kind_of Symbol
    end
    
    it 'calls #to_proc on a Symbol constraint' do
      c = mock
      c.expects(:respond_to?).with(:to_proc).returns(true)
      c.expects(:to_proc)
      
      subject.new :a, :constraint => c
    end
    
    it 'merges given options with DEFAULTS' do
      opts = {:optional => true}
      Clive::Argument::DEFAULTS.expects(:merge).with(opts).returns({})
      subject.new('arg', opts)
    end
    
    it 'finds the correct type class' do
      subject.new(:a, :type => String).type.must_equal Clive::Type::String
    end
    
    it 'uses the class passed if type cannot be found' do
      type = Class.new
      subject.new(:a, :type => type).type.must_equal type
    end
  end
  
  describe '#optional?' do
    it 'is true if the argument is optional' do
      subject.new(:arg, :optional => true).must_be :optional?
    end
    
    it 'is false if the argument is not optional' do
      subject.new(:arg, :optional => false).wont_be :optional?
    end
    
    it 'is false by default' do
      subject.new(:arg).wont_be :optional?
    end
  end
  
  describe '#to_s' do
    it 'surrounds the name by < and >' do
      subject.new(:a).to_s.must_equal '<a>'
    end
    
    it 'surrounds optional arguments with [ and ]' do
      subject.new(:a, :optional => true).to_s.must_equal '[<a>]'
    end
  end
  
  describe '#choice_str' do
    it 'returns the array of values allowed' do
      subject.new(:a, :within => %w(a b c)).choice_str.must_equal '(a, b, c)'
    end
    
    it 'returns the range of values allowed' do
      subject.new(:a, :within => 1..5).choice_str.must_equal '(1..5)'
    end
  end
  
  describe '#possible?' do
    describe 'for @type' do
      subject { Clive::Argument.new :a, :type => Clive::Type::Time }
      
      it 'is true for correct string values' do
        subject.must_be :possible?, '12:34'
      end
      
      it 'is true for objects of type' do
        subject.must_be :possible?, Time.parse('12:34')
      end
      
      unless RUBY_VERSION == '1.8.7' # No big problem so just ignore
        it 'is false for incorrect values' do
          subject.wont_be :possible?, 'not-a-time'
        end
      end
    end
    
    describe 'for @match' do
      subject { Clive::Argument.new :a, :match => /^[a-e]+![f-o]+\?.$/ }
      
      it 'is true for matching values' do
        subject.must_be :possible?, 'abe!off?.'
      end
      
      it 'is false for non-matching values' do
        subject.wont_be :possible?, 'off?abe!.'
      end
    end
    
    describe 'for @within' do
      subject { Clive::Argument.new :a, :within => %w(dog cat fish) }
      
      it 'is true for elements included in the collection' do
        subject.must_be :possible?, 'dog'
      end
      
      it 'is false for elements not in the collection' do
        subject.wont_be :possible?, 'mouse'
      end
    end
    
    describe 'for @constraint' do
      subject { Clive::Argument.new :a, :constraint => proc {|i| i.size == 5 } }
      
      it 'is true if the proc returns true' do
        subject.must_be :possible?, 'abcde'
      end
      
      it 'is false if the proc returns false' do
        subject.wont_be :possible?, 'abcd'
      end
    end
  end
  
  describe '#coerce' do
    it 'uses @type to return the correct object' do
      type = mock
      type.expects(:typecast).with('str').returns(5)
      subject.new(:a, :type => type).coerce("str").must_equal 5
    end
  end
end
