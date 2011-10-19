$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Type do

  subject { Clive::Type }
  let(:instance) { Clive::Type.new }
  
  describe '#valid?' do
    it 'returns false' do
      instance.valid?('arg').must_be_false
    end
  end
  
  describe '#typecast' do
    it 'returns nil' do
      instance.typecast('arg').must_be_nil
    end
  end
  
  describe '.find_class' do
    it 'returns the correct Type subclass' do
      s = Clive::Type::Integer
      subject.find_class('Integer').must_equal s
      subject.find_class('Clive::Integer').must_equal s
      subject.find_class('I::Dont::Exist::Integer').must_equal s
    end
    
    it 'returns nil if it can not be found' do
      subject.find_class('What::No').must_be_nil
    end
  end
  
  describe '.match' do
    it 'sets a proc given a symbol' do
      sym, obj = MiniTest::Mock.new, Object.new
      sym.expect :to_proc, obj, []
      
      subject.match sym
      subject.instance_variable_get(:@valid).must_equal obj
      sym.verify
    end
    
    it 'sets a proc given a regular expression' do
      subject.match /a|b|c/
      subject.instance_variable_get(:@valid).class.must_equal Proc
    end
  end
  
  describe '.refute' do
    it 'sets a proc given a symbol' do
      subject.refute :odd?
      subject.instance_variable_get(:@valid).class.must_equal Proc
    end
    
    it 'sets a proc given a regular expression' do
      subject.refute /a|b|c/
      subject.instance_variable_get(:@valid).class.must_equal Proc
    end
  end
  
  describe '.cast' do
    it 'sets a symbol' do
      subject.cast :to_i
      subject.instance_variable_get(:@cast).must_equal :to_i
    end
  end
  
  describe '.valid?' do
    describe 'if @valid has been set' do
      it 'calls the block' do
        sym, prc = MiniTest::Mock.new, MiniTest::Mock.new
        sym.expect :to_proc, prc, []
        prc.expect :call, true, ['arg']
        
        subject.match sym
        subject.valid? 'arg'
        sym.verify; prc.verify
      end
    end
    
    describe 'if @valid has not been set' do
      it 'calls #valid?' do
        subject.must_receive(:valid?).with('arg')
        subject.valid? 'arg'
      end
    end
  end
  
  describe '.typecast' do
    describe 'if @cast has been set' do
      it 'uses the method set' do
        arg = MiniTest::Mock.new
        arg.expect :send, true, [:to_i]
        
        subject.cast :to_i
        subject.typecast arg
        arg.verify
      end
    end
    
    describe 'if @cast has not been set' do
      it 'calls #typecast' do
        subject.must_receive(:typecast).with('arg')
        subject.valid? 'arg'
      end
    end
  end
  
end