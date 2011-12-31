$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Option do
  subject { Clive::Option }
  
  def option_with(opts, &block)
    Clive::Option.new [:o, :opt], "", opts, &block
  end
  
  describe '#initialize' do
    it 'sorts names by size' do
      subject.new([:zz, :a]).names.must_equal [:a, :zz]
      subject.new([:aa, :z]).names.must_equal [:z, :aa]
    end
    
    let(:opt) { option_with :head => true, :args => '<a> <b>', :as => [String, Integer] }
    
    it 'finds all options' do
      opt.opts.must_include :head
      opt.opts.wont_include :args
    end
    
    it 'uses default options when not set' do
      opt.opts.must_include :runner
    end
    
    it 'creates the args list' do
      opt.args.first.must_be_argument :name => :a, :type => Clive::Type::String
      opt.args.last.must_be_argument :name => :b, :type => Clive::Type::Integer
    end
  end
  
  describe '#short' do
    it 'returns the short name' do
      opt = subject.new [:o, :opt]
      opt.short.must_equal :o
    end
    
    it 'returns nil if no short name exists' do
      opt = subject.new [:opt]
      opt.short.must_be_nil
    end
  end
  
  describe '#long' do
    it 'returns the long name' do
      opt = subject.new [:o, :opt]
      opt.long.must_equal :opt
    end
    
    it 'returns nil if no long name exists' do
      opt = subject.new [:o]
      opt.long.must_be_nil
    end
  end
  
  describe '#name' do
    it 'returns the long name' do
      opt = subject.new [:opt, :o]
      opt.name.must_equal :opt
    end
    
    it 'returns the short name if no long name exists' do
      opt = subject.new [:o]
      opt.name.must_equal :o
    end
  end
  
  describe '#to_s' do
    it 'returns a string representation of the option' do
      opt = subject.new [:o, :opt]
      opt.to_s.must_equal "-o, --opt"
    end
    
    it 'adds a --[no-] prefix to boolean options' do
      opt = subject.new [:o, :opt], "", :boolean => true
      opt.to_s.must_equal "-o, --[no-]opt"
    end
    
    it 'uses dashes instead of underscores' do
      opt = subject.new [:S, :super_long_option_name]
      opt.to_s.must_equal "-S, --super-long-option-name"
    end
  end
  
  describe '#head?' do
    it 'is true if head is set to true' do
      option_with(:head => true).must_be :head?
    end
    
    it 'is false otherwise' do
      option_with({}).wont_be :head?
    end
  end
  
  describe '#tail?' do
    it 'is true if tail is set to true' do
      option_with(:tail => true).must_be :tail?
    end
    
    it 'is false otherwise' do
      option_with({}).wont_be :tail?
    end
  end
  
  describe '#boolean?' do
    it 'is true if boolean is set to true' do
      option_with(:boolean => true).must_be :boolean?
    end
    
    it 'is false otherwise' do
      option_with({}).wont_be :boolean?
    end
  end
  
  describe '#run' do
    let(:block) { proc {} }
    
    it 'calls Runner#_run with true if #boolean?' do
      t = mock
      t.expects(:_run).with([[:truth, true]], {}, block)
      ot = option_with :boolean => true, :runner => t, &block
      ot.run({}, [true])
    end
    
    it 'calls Runner#_run with false if #boolean?' do
      f = mock
      f.expects(:_run).with([[:truth, false]], {}, block)
      of = option_with :boolean => true, :runner => f, &block
      of.run({}, [false])
    end
  
    it 'calls Runner#_run with mapped args' do
      r = mock
      r.expects(:_run).with([[:a, 'a'], [:b, 'b']], {}, block)
      o = option_with :args => '<a> <b>', :runner => r, &block
      o.run({}, ['a', 'b'])
    end
    
    it 'sets state if no block exists' do
      o = option_with :args => '<a> <b>'
      state = Clive::StructHash.new
      o.run state, ['a', 'b']
      state[:opt].must_equal ['a', 'b']
    end
  end
  
  describe '#<=>' do
    let(:heada) { subject.new [:a], "", :head => true }
    let(:headz) { subject.new [:z], "", :head => true }
    let(:taila) { subject.new [:a], "", :tail => true }
    let(:tailz) { subject.new [:z], "", :tail => true }
    let(:aaa)  { subject.new [:aaa] }
    let(:zzz)  { subject.new [:zzz] }
  
    it 'puts head?s first' do
      heada.must_be :<, aaa
      heada.must_be :<, zzz
    end
    
    it 'compares 2 head?s alphabetically' do
      heada.must_be :<, headz
    end
    
    it 'puts tail?s last' do
      taila.must_be :>, aaa
      taila.must_be :>, zzz
    end
    
    it 'compares 2 tail?s alphabetically' do
      taila.must_be :<, tailz
    end
    
    it 'compares options based on #name' do
      aaa.must_be :<, zzz
    end
    
    it 'sorts options properly' do
      [taila, headz, tailz, zzz, heada, aaa].sort.
        must_equal [heada, headz, aaa, zzz, taila, tailz]
    end
  end
end
