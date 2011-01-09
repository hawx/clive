require 'spec_helper'

describe Clive::Flag do

  subject { Clive::Flag.new([:S, :say], "Say something", ["WORD(S)"]) {|i| $stdout.puts i } }

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
      subject { Clive::Flag.new([:n], "Description", ["REQ [OPT] REQ2 [OPT2] [OPT3]"]) }
    
      it "returns the number of all arguments" do
        subject.arg_size(:all).should == 5
      end
      
      it "returns the number of optional arguments" do
        subject.arg_size(:optional).should == 3
      end
      
      it "returns the number of mandatory arguments" do
        subject.arg_size(:mandatory).should == 2
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
        "names" => %w(-S --say),
        "desc"  => "Say something",
        "args"  => "<WORD(S)>",
        "options" => ""
      }
      subject.to_h.should == hsh
    end
  end
  
end