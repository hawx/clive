require 'spec_helper'

describe Clive::Bool do

  subject { Clive::Bool.new([:n, :name], "A test", true) {|arg| $stdout.puts arg } }
  let(:falsey) { Clive::Bool.new([:n, :name], "A test", false) {|arg| $stdout.puts arg } }

  describe "#truth" do
    it "returns the truth" do
      subject.truth.should == true
    end
  end

  it_behaves_like "an option"
  
  context "when no long name is given" do
    it "raises an error" do
      expect {
        Clive::Bool.new([:n], "Short test", true) {}
      }.should raise_error Clive::MissingLongName
    end
  end
  
  describe "#run" do
    context "when truth is true" do
      it "passes true to the block" do
        $stdout.should_receive(:puts).with(true)
        subject.run
      end
    end
    
    context "when truth is false" do
      it "passes false to the block" do
        $stdout.should_receive(:puts).with(false)
        falsey.run
      end
    end
  end
  
  describe "#to_h" do
    context "when truth is true" do
      it "returns hash for help formatter" do
        hsh = {'names' => subject.names_to_strings(true),
               'desc' => subject.desc}
        subject.to_h.should == hsh
      end
    end
    
    context "when truth is false" do
      specify { falsey.to_h.should be_nil }
    end
  end

end
