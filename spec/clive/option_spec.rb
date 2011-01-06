require 'spec_helper'

describe Clive::Option do
  subject { Clive::Option.new([:n, :names], "A test option") { puts "hi" } }

  it_behaves_like "an option"
  
  describe "#run" do
    it "calls the block" do
      $stdout.should_receive(:puts).with("hi")
      subject.run
    end
  end
  
  describe "#sort_name" do
    it "returns the name to sort by" do
      subject.sort_name.should == 'n'
    end
  end
  
  describe "#<=>" do
    it "sorts by #sort_name" do
      other = Clive::Option.new([:z, :apple], "Another") {}
      (subject <=> other).should == -1
    end
  end
  
  describe "#to_h" do
    it "returns a hash for help" do
      hsh = {"names" => subject.names_to_strings, "desc" => subject.desc}
      subject.to_h.should == hsh
    end
  end
end