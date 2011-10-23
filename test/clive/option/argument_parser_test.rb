$: << File.dirname(__FILE__) + '/../..'
require 'helper'

describe Clive::Option::ArgumentParser do

  subject { Clive::Option::ArgumentParser }

  def args_for(opts)
    subject.new opts, Clive::Option::OPT_KEYS
  end
  
  def defaults_and(opts)
    Clive::Argument::DEFAULTS.merge(opts)
  end

  it 'separates options' do
    s = args_for :args => '<a>', :head => true, :within => 1..5
    s.opts.must_equal :head => true
  end
  
  it 'separates arguments' do
    s = args_for :args => '<a>', :head => true, :within => 1..5
    s.args.first.must_be_argument :name => :a, :within => 1..5
  end
  
  it 'normalises names' do
    s = args_for :name => :arg, :as => Integer, :in => 1..5, :defaults => 3
    s.args.first.must_be_argument :name => :arg, :type => Clive::Type::Integer, 
                                  :within => 1..5, :default => 3
  end
  
  describe 'inferring arguments' do
    it 'infers argument with :within' do
      s = args_for :within => %w(small medium large)
      s.args.size.must_equal 1
      s.args.first.must_be_argument :name => :arg, :within => %w(small medium large)
      
      s = args_for :within => [%w(small medium large), %w(wide thin)]
      s.args.size.must_equal 2
      s.args[0].must_be_argument :name => :arg, :within => %w(small medium large)
      s.args[1].must_be_argument :name => :arg, :within => %w(wide thin)
    end
    
    it 'infers argument with :match' do
      s = args_for :match => /\d+/
      s.args.size.must_equal 1
      s.args.first.must_be_argument :name => :arg, :match => /\d+/
      
      s = args_for :match => [/\d+/, /\d+/, /\d+/]
      s.args.size.must_equal 3
      s.args.all? {|arg| arg.must_be_argument :name => :arg, :match => /\d+/ }
    end
    
    it 'infers argument with :as' do
      s = args_for :type => Symbol
      s.args.size.must_equal 1
      s.args.first.must_be_argument :name => :arg, :type => Clive::Type::Symbol
      
      s = args_for :type => [String, Integer]
      s.args.size.must_equal 2
      s.args[0].must_be_argument :name => :arg, :type => Clive::Type::String
      s.args[1].must_be_argument :name => :arg, :type => Clive::Type::Integer
    end
    
    it 'infers argument with :default' do
      s = args_for :default => "large"
      s.args.size.must_equal 1
      s.args.first.must_be_argument :name => :arg, :optional => true, :default => "large"
      
      s = args_for :default => ["large", 5]
      s.args.size.must_equal 2
      s.args[0].must_be_argument :name => :arg, :optional => true, :default => "large"
      s.args[1].must_be_argument :name => :arg, :optional => true, :default => 5
    end
    
    it 'infers argument with multiple options correctly' do
      s = args_for :default => :large, :type => Symbol
      s.args.size.must_equal 1
      s.args.first.must_be_argument :name => :arg, :optional => true, 
                                    :type => Clive::Type::Symbol, :default => :large
    end
  end
end

