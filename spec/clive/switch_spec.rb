require 'spec_helper'

describe Clive::Switch do
  subject { Clive::Switch.new([:n, :names], "A description") { puts "hi" } }

  it_behaves_like "an option"
  
  describe "#run" do
    it "calls the block" do
      $stdout.should_receive(:puts).with("hi")
      subject.run
    end
  end
end