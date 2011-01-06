require 'spec_helper'

describe Clive::Tokens do

  subject { Clive::Tokens.new %w(word --long -sa) }
  
  
  describe "#array" do
    it "returns array of strings" do
      subject.array.should == ["word", "--long", "-s", "-a"]
    end
  end
  
  describe "#tokens" do
    it "returns array of tokens" do
      subject.tokens.should == [[:word, "word"], [:long, "long"], [:short, "s"], [:short, "a"]]
    end
  end
  
  describe "#<<" do
    subject { Clive::Tokens.new }
    
    context "when adding token" do
      it "adds as a string" do
        subject << [:long, "test"]
        subject.tokens.should == [[:long, "test"]]
      end
    end
    
    context "when adding string" do
      it "adds normally" do
        subject << "--test"
        subject.tokens.should == [[:long, "test"]]
      end
    end
  end
  
end