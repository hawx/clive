require 'spec_helper'

describe Clive::Flag do

  subject { Clive::Flag.new([:S, :say], "Say something", ["WORD(S)"]) {|i| puts i } }

  it_behaves_like "an option"
  
  describe "#args" do
    it "returns a hash with argument(s)" do
      subject.args.should == [{:name => "WORD(S)", :optional => false}]
    end
  end

  describe "#run" do
    it "calls the block with the argument" do
      $stdout.should_receive(:puts).with("hey")
      subject.run(["hey"])
    end
  end
  
  describe "#arg_num" do
    it "returns the number of arguments" do
      subject.arg_num(false).should == 1
    end
  end
  
  describe "#args_to_strings" do
    it "converts the arguments to strings" do
      subject.args_to_strings.should == ["WORD(S)"]
    end
  end
  
  describe "#arg_size" do
    context "when choice is available" do
      it "returns 1" do
        subject.args = 1..5
        subject.arg_size.should == 1
      end
    end
    
    context "when arguments are required" do
      it "returns the number of arguments" do
        subject.args = [{:name => "ARG", :optional => false}]
        subject.arg_size.should == 1
      end
    end
  end
  
  describe "#options_to_strings" do
    context "when @args is a range" do
      it "returns array with range as string" do
        subject.args = 1..4
        subject.options_to_strings.should == ["1..4"]
      end
    end
    
    context "when @args is a hash" do
      it "converts the options to strings" do
        subject.options_to_strings.should == [""]
      end
    end
    
    context "when @args is an array" do
      it "returns the array" do
        subject.args = %w(1 2 3 4)
        subject.options_to_strings.should == %w(1 2 3 4)
      end
    end
  end
  
  describe "#to_h" do
    it "returns a hash" do
      hsh = {
        "names" => Clive::Array.new(%w(-S --say)),
        "desc"  => "Say something",
        "args"  => Clive::Array.new(["WORD(S)"]),
        "options" => Clive::Array.new([""])
      }
      subject.to_h.should == hsh
    end
  end
  
end