$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Arguments do

  subject {
    Clive::Arguments.create :args => '[<a>] <b> <c> [<d>]', 
                            :type => [Integer] * 4,
                            :constraint => [:even?, :odd?] * 2
  }
  
  describe '.create' do
    it 'parses the options passed using Parser' do
      parser, opts = mock, stub
      parser.expects(:to_args).returns([])
      Clive::Arguments::Parser.expects(:new).with(opts).returns(parser)
      Clive::Arguments.create opts
    end
    it 'returns a list of Argument instances' do
      a = Clive::Arguments.create :args => '[<a>] <b>', :as => [Integer, nil], :in => [1..5, nil]
      a[0].must_be_argument :name => :a, :optional => true, :within => 1..5, 
                            :type => Clive::Type::Integer
      a[1].must_be_argument :name => :b, :optional => false
    end
  end

  describe '#zip' do
    it 'zips arguments properly' do
      def subject.simple_zip(other); zip(other).map(&:last); end
    
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
     Clive::Arguments.new( [
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
  
  describe '#min' do
    it 'returns the number of non-optional arguments' do
      subject.min.must_equal 2
    end
  end
  
  describe '#max' do
    it 'returns the total number of arguments' do
      subject.max.must_equal 4
    end
  end
  
  describe '#possible?' do
    it 'is true if each argument is possible and list is not too long' do
      subject.must_be :possible?, [2]
      subject.must_be :possible?, [2, 3]
      subject.must_be :possible?, [2, 3, 4]
      subject.must_be :possible?, [2, 3, 4, 5]
    end
    
    it 'is false if the list is too long' do
      subject.wont_be :possible?, [2, 3, 4, 5, 6]
    end
    
    it 'is true even if an argument is not possible' do
      subject.must_be :possible?, ['hello']
    end
    
    it 'single' do
      subject = Clive::Arguments.create :arg => '<name>'
      subject.must_be :possible?, []
      subject.must_be :possible?, %w(John)
      subject.wont_be :possible?, %w(John Doe)
    end
    
    it 'single optional' do
      subject = Clive::Arguments.create :arg => '[<name>]'
      subject.must_be :possible?, []
      subject.must_be :possible?, %w(John)
      subject.wont_be :possible?, %w(John Doe)
    end
    
    it 'single with constraint' do
      subject = Clive::Arguments.create :arg => '<name>', :constraint => proc {|i| i.size == 4 }
      subject.must_be :possible?, []
      subject.must_be :possible?, %w(John)
      subject.wont_be :possible?, %w(James)
      subject.wont_be :possible?, %w(John Doe)
    end
    
    it 'single optional with constraint' do
      subject = Clive::Arguments.create :arg => '[<name>]', :constraint => proc {|i| i.size == 4 }
      subject.must_be :possible?, []
      subject.must_be :possible?, %w(John)
      subject.wont_be :possible?, %w(James)
      subject.wont_be :possible?, %w(John Doe)
    end
  
    it 'multiple surrounding' do
      subject = Clive::Arguments.create :args => '<first> [<middle>] <last>'
      subject.must_be :possible?, []
      subject.must_be :possible?, %w(John)
      subject.must_be :possible?, %w(John Doe)
      subject.must_be :possible?, %w(John David Doe)
      subject.wont_be :possible?, %w(John David James Doe)
    end
    
    it 'multiple middle' do
      subject = Clive::Arguments.create :args => '[<first>] <middle> [<last>]'
      subject.must_be :possible?, []
      subject.must_be :possible?, %w(John)
      subject.must_be :possible?, %w(John Doe)
      subject.must_be :possible?, %w(John David Doe)
      subject.wont_be :possible?, %w(John David James Doe)
    end
    
    it 'multiple surrounding with constraints' do
      subject = Clive::Arguments.create :args => '<first> [<middle>] <last>',
        :constraint => [proc {|i| i.size == 3 }, proc {|i| i.size == 4 }, proc {|i| i.size == 5 }]
      subject.must_be :possible?, []
      
      subject.must_be :possible?, %w(Joe)   # [Joe, ..., ...]
      subject.wont_be :possible?, %w(Gary)  # [!!!, Gary, ...]
      subject.wont_be :possible?, %w(David) # [!!!, nil, David]
      
      subject.must_be :possible?, %w(Joe Gary)   # [Joe, Gary, ...]
      subject.must_be :possible?, %w(Joe David)  # [Joe, ..., David]
      subject.wont_be :possible?, %w(Gary David) # [!!!, Gary, David]
      
      subject.must_be :possible?, %w(Joe Gary David)     # [Joe, Gary, David]
      subject.wont_be :possible?, %w(Joe Gary David Doe) # [Joe, Gary, David] Doe
    end
  end
  
  describe '#valid?' do
    it 'is false if the list is not #possible' do
      subject.stubs(:possible?).returns(false)
      subject.wont_be :valid?, [1, 2]
    end
    
    it 'is false if the list is too short' do
      subject.stubs(:possible?).returns(true)
      subject.wont_be :valid?, [1]
    end
    
    it 'is true if the list is #possible? and not too short' do
      subject.stubs(:possible?).returns(true)
      subject.must_be :valid?, [1, 2]
      subject.must_be :valid?, [1, 2, 3]
      subject.must_be :valid?, [0, 1, 2, 3]
    end
  end
  
  describe '#create_valid' do
    it 'returns the correct arguments' do
      a = Clive::Arguments.create :args => '[<a>] <b> [<c>]'
      a.create_valid(%w(a b c)).must_equal ['a', 'b', 'c']
      a.create_valid(%w(a b)).must_equal ['a', 'b', nil]
      a.create_valid(%w(a)).must_equal [nil, 'a', nil]
    end
    
    it 'coerces the arguments' do
      a = Clive::Arguments.create :args => '<a> <b>', :as => [Integer, Float]
      a.create_valid(%w(50.55 50.55)).must_equal [50, 50.55]
    end
    
    it 'uses defaults where needed' do
      a = Clive::Arguments.create :args => '[<a>] <b> [<c>]', :defaults => ['y', nil, 'y']
      a.create_valid(%w(n)).must_equal %w(y n y)
    end
  end

end
