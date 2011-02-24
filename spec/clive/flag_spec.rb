require 'spec_helper'

describe Clive::Flag do

  subject { Clive::Flag.new([:S, :say], "Say something", "WORD(S)") {|i| $stdout.puts i } }

  it_behaves_like "an option"

  describe "#run" do
    it "calls the block with the argument" do
      $stdout.should_receive(:puts).with("hey")
      subject.run(["hey"])
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
      subject { Clive::Flag.new([:n], "Description", "REQ [OPT] REQ2 [OPT2] [OPT3]") }
    
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
  
  describe "#args_to_string" do
  
    context "when a list of options" do
      it "returns the arguments as a string" do
        subject.args = "first [second]"
        subject.args_to_string.should == "<first> [second]"
      end
    end
    
    context "when a splat as option" do
      it "returns the argument and ellipsis" do
        subject.args = "arg..."
        subject.args_to_string.should == "<arg1> ..."
      end
    end
    
    context "when a choice of options" do
      it "returns an empty string" do
        subject.args = %w(a b c)
        subject.args_to_string.should == ""
      end
    end
    
    context "when a range of options" do
      it "returns an empty string" do
        subject.args = 1..5
        subject.args_to_string.should == ""
      end
    end
    
  end
  
  describe "#options_to_string" do
  
    context "when a list of options" do
      it "returns an empty string" do
        subject.args = "first [second]"
        subject.options_to_string.should == ""
      end
    end
    
    context "when a splat as option" do
      it "returns an empty string" do
        subject.args = "arg..."
        subject.options_to_string.should == ""
      end
    end
    
    context "when a choice of options" do
      it "returns the choices joined" do
        subject.args = %w(a b c)
        subject.options_to_string.should == "(a, b, c)"
      end
    end
    
    context "when a range of options" do
      it "returns a string representation of the range" do
        subject.args = 1..5
        subject.options_to_string.should == "(1..5)"
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