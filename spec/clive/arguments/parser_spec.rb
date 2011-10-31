$: << File.dirname(__FILE__) + '/../..'
require 'helper'

class Clive::Arguments::ParserSubject < Clive::Arguments::Parser
  attr_reader :opts
end

describe Clive::Arguments::Parser do

  subject { Clive::Arguments::ParserSubject }

  describe '#initialize' do
    it 'normalises key names' do
      subject.new(:kind => String, :in => %w(a b c)).opts.keys.must_include :type, :within
    end
  end
  
  describe '#to_a' do
    it 'returns an array of hashes' do
      subject.new(:type => [Integer, Time]).to_a.must_equal [{:type => Integer, :name => 'arg'},
                                                             {:type => Time, :name => 'arg'}]
    end
  end
  
  describe '#to_args' do
    it 'returns an array of Argument instances' do
      args = subject.new(:args => '<a> <b> [<c>]', :type => [Integer, Time]).to_args
      args.size.must_equal 3
      args[0].must_be_argument :name => :a, :type => Clive::Type::Integer
      args[1].must_be_argument :name => :b, :type => Clive::Type::Time
      args[2].must_be_argument :name => :c, :optional => true
    end
  end

end