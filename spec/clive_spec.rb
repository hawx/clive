$: << File.dirname(__FILE__)
require 'helper'

# For some reason Class.new(Clive) { Boolean } throws an error?
class IncludingCliveReferenceTest < Clive
  opt :name, :as => Boolean
end

describe Symbol do
  describe '#<=>' do
    it 'compares the symbols like strings' do
      (:a <=> :b).must_equal ('a' <=> 'b')
      (:a <=> :a).must_equal ('a' <=> 'a')
    end
  end
end

describe Clive do

  describe 'inheriting Clive' do
    subject { Class.new(Clive) }
  
    it 'responds to all the methods in Base' do
      (Clive::Base.instance_methods - Object.instance_methods).each do |meth|
        subject.must_respond_to meth.to_sym
      end
    end
    
    it 'allows you to reference Types' do
      IncludingCliveReferenceTest.find('--name').args.first.type.must_equal Clive::Type::Boolean
    end
    
    it 'allows you to get the Base instance' do
      subject.instance.must_be_kind_of Clive::Base
    end
  end
  
  describe 'initializing Clive' do
    subject { Clive.new }
    
    it 'actually initializes Clive::Base' do
      subject.must_be_instance_of Clive::Base
    end
    
    it 'does not allow you to reference Types' do
      this { Clive.new { Boolean } }.must_raise NameError
    end
    
  end
  
  describe 'Clive#()' do
    subject { Clive(:verbose, [:b, :bare]) }  
  
    it 'creates an option for symbols passed' do
      subject.must_have_option :verbose
    end
    
    it 'uses both names if given as an array' do
      subject.find_option(:b).must_equal subject.find_option(:bare)
    end
  end

end


