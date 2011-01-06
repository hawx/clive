require 'spec_helper'

describe Clive::Parser do

  subject {
    class CLI
      include Clive::Parser
    end
    CLI
  }
  
  it "keeps track of its class" do
    subject.instance_variable_get("@klass").should == CLI
  end
  
  describe "#base" do
    it "has a 'base' command" do
      subject.base.should be_kind_of Clive::Command
    end
  end
  
  describe "#parse" do
    it "should call #run on 'base'" do
      subject.base.should_receive(:run).with([])
      subject.parse([])
    end
  end
  
  describe "#flag" do
    it "adds a new flag to 'base'" do
      expect {
        subject.flag(:t, :test, :arg => "NAME") {|i| puts i }
      }.should change {subject.base.flags.size}.by(1)
    end
  end
  
  describe "#switch" do
    it "adds a new switch to 'base'" do
      expect {
        subject.switch(:t, :test) {}
      }.should change {subject.base.switches.size}.by(1)
    end
  end

  describe "#command" do
    it "adds a new command to 'base'" do
      expect {
        subject.command(:command) {}
      }.should change {subject.base.commands.size}.by(1)
    end
  end
  
  describe "#bool" do
    it "adds a new bool to 'base'" do
      expect {
        subject.bool(:boo) {}
      }.should change {subject.base.bools.size}.by(2)
    end
  end
  
  describe "#desc" do
    it "sets current desc for 'base'" do
      subject.desc "test"
      subject.base.instance_variable_get("@current_desc").should == "test"
    end
  end
  
  describe "#help_formatter" do
    it "sets the help formatter for 'base'" do
      subject.base.should_receive(:help_formatter).with(:white)
      subject.help_formatter(:white)
    end
  end
  
  describe "#option_var" do
    before { subject.option_var(:test, 1) }
  
    it "creates a getter" do
      subject.should respond_to :test
    end
    
    it "creates a setter" do
      subject.should respond_to :test=
      subject.test = 2
    end
    
    it "sets a default value" do
      subject.test.should == 1
    end
  end
  
  describe "#option_hash" do
    it "uses #option_var with empty hash" do
      subject.should_receive(:option_var).with(:test, {})
      subject.option_hash(:test)
    end
  end
  
  describe "#option_array" do
    it "uses #option_var with empty array" do
      subject.should_receive(:option_var).with(:test, [])
      subject.option_array(:test)
    end
  end

end