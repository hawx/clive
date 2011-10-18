$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::ArgumentList do
  describe '#zip' do
    subject {
      a = Clive::Argument.new :a, :type => Integer, :constraint => :even?, :optional => true
      b = Clive::Argument.new :b, :type => Integer, :constraint => :odd?
      c = Clive::Argument.new :c, :type => Integer, :constraint => :even?
      d = Clive::Argument.new :d, :type => Integer, :constraint => :odd?, :optional => true
      
      list = Clive::ArgumentList.new([a, b, c, d])
      
      def list.simple_zip(other); zip(other).map {|i| i[1] }; end
      list
    }
  
    it 'zips arguments properly' do
      # These behaviours are definitely what should happen
      subject.simple_zip(%w(1 4)).must_equal     [nil, '1', '4', nil]
      subject.simple_zip(%w(1 4 3)).must_equal   [nil, '1', '4', '3']
      subject.simple_zip(%w(2 1 4 3)).must_equal ['2', '1', '4', '3']
      subject.simple_zip(%w(2 1 4)).must_equal   ['2', '1', '4', nil]
      
      # These behaviours may change
      subject.simple_zip(%w(2)).must_equal   [nil, nil, '2', nil]
      subject.simple_zip(%w(1)).must_equal   [nil, '1', nil, nil]
      subject.simple_zip(%w(2 1)).must_equal [nil, nil, '2', nil]
    end  
  end
  
  describe '#to_s' do
    subject {
     Clive::ArgumentList.new( [
       Clive::Argument.new(:a), 
       Clive::Argument.new(:b, :optional => true),
       Clive::Argument.new(:c, :optional => true),
       Clive::Argument.new(:d)
     ])
    }
  
    it 'removes extra square brackets' do
      subject.to_s.must_equal "<a> [<b> <c>] <d>"
    end
  end
end
