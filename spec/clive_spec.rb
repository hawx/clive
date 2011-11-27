$: << File.dirname(__FILE__)
require 'helper'

# For some reason Class.new(Clive) { Boolean } throws an error?
class IncludingCliveReferenceTest < Clive
  opt :name, as: Boolean
end

describe Clive do

  describe 'inheriting Clive' do
    subject { Class.new(Clive) }
  
    it 'responds to all the methods in Base' do
      (Clive::Base.instance_methods - Object.instance_methods).each do |meth|
        subject.must_respond_to meth
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
    
    it 'responds to all the methods in Base' do
      (Clive::Base.instance_methods - Object.instance_methods).each do |meth|
        subject.must_respond_to meth
      end
    end
    
    it 'does not allow you to reference Types' do
      this { Clive.new { Boolean } }.must_raise NameError
    end
    
    it 'allows you to get the Base instance' do
      subject.instance.must_be_kind_of Clive::Base
    end
    
  end

end


