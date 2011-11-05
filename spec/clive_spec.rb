$: << File.dirname(__FILE__)
require 'helper'

# For some reason Class.new { extend Clive; Boolean } throws an error?
class IncludingCliveReferenceTest
  extend Clive
  opt :name, as: Boolean
end

describe Clive do

  describe 'extending Clive' do
    subject { Class.new { extend Clive } }
  
    it 'responds all the methods in TopCommand' do
      (Clive::TopCommand.instance_methods - Object.instance_methods).each do |meth|
        subject.must_respond_to meth
      end
    end
    
    it 'allows you to reference Types' do
      IncludingCliveReferenceTest.find('--name').args.first.type.must_equal Clive::Type::Boolean
    end
    
    it 'allows you to get the TopCommand instance' do
      subject.top.must_be_kind_of Clive::TopCommand
    end
  end
  
  describe 'including Clive' do
    it 'extends Clive' do
      m = Class.new
      m.expects(:extend).with(Clive)
      m.send(:include, Clive)
    end
  end

end


