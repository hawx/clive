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
    
    it 'uses ArgumentParser to set opts and args' do
      Clive::Option::ArgumentParser.expects(:new).with Clive::Option::OPT_KEYS, 
                                        Clive::Option::ARG_KEYS,
                                        :head => true, :args => '<a> <b>'
      option_with :head => true, :args => '<a> <b>'
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
      t = MiniTest::Mock.new
      t.expect :_run, nil, [[[:truth, true]], {}, block]
      ot = option_with :boolean => true, :runner => t, &block
      ot.run({}, [true])
      t.verify
    end
    
    it 'calls Runner#_run with false if #boolean?' do
      f = MiniTest::Mock.new
      f.expect :_run, nil, [[[:truth, false]], {}, block]
      of = option_with :boolean => true, :runner => f, &block
      of.run({}, [false])
      f.verify
    end
  
    it 'calls Runner#_run with mapped args' do
      r = MiniTest::Mock.new
      r.expect :_run, nil, [[[:a, 'a'], [:b, 'b']], {}, block]
      o = option_with :args => '<a> <b>', :runner => r, &block
      o.run({}, ['a', 'b'])
      r.verify
    end
    
    it 'sets state if no block exists' do
      o = option_with :args => '<a> <b>'
      state = {}
      o.run state, ['a', 'b']
      state[:opt].must_equal ['a', 'b']
    end
  end
  
  # possibly move to ArgumentList
  describe '#min_args' do
    it 'is the number of arguments that must be given' do
      option_with(:args => '<a> <b> [<c> <d>]').min_args.must_equal 2
    end
  end
  
  # possibly move to ArgumentList
  describe '#max_args' do
    it 'is the maximum number of arguments that can be given' do
      option_with(:args => '<a> <b> [<c> <d>]').max_args.must_equal 4
    end
  end
  
  # possibly move to ArgumentList
  describe '#possible?' do
    subject do
      option_with :args => '<a> <b> [<c>]', 
                  :constraint => [proc {|a| a == 'a' }, proc {|b| b == 'b' }]
    end
  
    it 'is true if each argument is possible and list is not too long' do
      subject.must_be :possible?, %w(a)
      subject.must_be :possible?, %w(a b)
      subject.must_be :possible?, %w(a b c)
    end
    
    it 'is false if the list is too long' do
      subject.wont_be :possible?, %w(a b c d)
    end
    
    it 'is false if an argument is not possible' do
      subject.wont_be :possible?, %w(d)
    end
  end
  
  # possibly move to ArgumentList
  describe '#valid?' do
    subject { option_with :args => '<a> <b> [<c>]' }
  
    it 'is false if the list is not #possible?' do
      subject.stub(:possible?, false)
      subject.wont_be :valid?, %w(a b)
    end
    
    it 'is false if the list is too short' do
      subject.stub(:possible?, true)
      subject.wont_be :valid?, %w(a)
    end
    
    it 'is true if the list is #possible? and not too short' do
      subject.stub(:possible?, true)
      subject.must_be :valid?, %w(a b)
      subject.must_be :valid?, %w(a b c)
    end
  end
  
  # possibly move to ArgumentList
  describe '#valid_arg_list' do
    it 'returns the correct arguments' do
      o = option_with :args => '[<a>] <b> [<c>]'
      o.valid_arg_list(%w(a b c)).must_equal ['a', 'b', 'c']
      o.valid_arg_list(%w(a b)).must_equal ['a', 'b', nil]
      o.valid_arg_list(%w(a)).must_equal [nil, 'a', nil]
    end
    
    it 'coerces the arguments' do
      o = option_with :args => '<a> <b>', :as => [Integer, Float]
      o.valid_arg_list(%w(50.00 50.00)).must_equal [50, 50.0]
    end
    
    it 'uses defaults where needed' do
      o = option_with :args => '[<a>] <b> [<c>]', :defaults => ['y', nil, 'y']
      o.valid_arg_list(%w(n)).must_equal ['y', 'n', 'y']
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

class OptionTest < MiniTest::Unit::TestCase
  
  # TODO
  def test_can_add_infinite_args
    o = Clive::Option.new([:add], "", {:args => "<item>..."})
    assert_equal Infinite, o.args.size
    assert_argument [:arg1, false, nil, nil, nil], o.args.first
  end

end
