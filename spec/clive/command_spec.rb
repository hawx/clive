require 'spec_helper'

describe Clive::Command do

  context "when creating a base command" do
    subject { Clive::Command.setup(Class.new) {} }
  end
  
  subject { 
    Clive::Command.new([:co, :comm], "A command", Class.new) do
      bool(:boo) {}
      switch(:swi) {}
      flag(:fla) {}
      command(:com) {}
    end
  }
  
  it_behaves_like "an option"
  
  describe "#initialize" do
    subject { 
      Clive::Command.new([:com], "A command", Class.new) do
        flag(:test)
      end
    }
  
    it "generates a help header" do
      File.stub!(:basename).and_return("test")
      subject.instance_variable_get("@header").should == "Usage: test com [options]"
    end
    
    it "generates an option missing proc" do
      proc = subject.instance_variable_get("@option_missing")
      expect {
        proc.call("hey")
      }.should raise_error Clive::NoOptionError
    end
    
    it "doesn't run the block given" do
      subject.flags.size.should == 0
    end
    
    it "generates a help switch" do
      subject.switches.map {|i| i.names}.should include ["h", "help"]
    end
  end
  
  describe "#bools" do
    it "returns an array of bools" do
      subject.find
      subject.bools.each do |i|
        i.should be_kind_of Clive::Bool
      end
    end
  end
  
  describe "#switches" do
    it "returns an array of switches" do
      subject.find
      subject.switches.each do |i|
        i.should be_kind_of Clive::Switch
      end
    end
  end
  
  describe "#flags" do
    it "returns an array of flags" do
      subject.find
      subject.flags.each do |i|
        i.should be_kind_of Clive::Flag
      end
    end
  end
  
  describe "#find" do
    it "runs the block for the command" do
      subject.flags.size.should == 0
      subject.find
      subject.flags.size.should == 1
    end
    
    it "sets the block to nil" do
      subject.find
      subject.block.should be_nil
    end
  end
  
  describe "#run" do
    it "returns an array of unused arguments" do
      subject.find
      subject.run(%w(--swi what)).should == ['what']
    end
  end
  
  describe "#to_h" do
    it "returns a hash of data for help formatting" do
      hsh = {'names' => subject.names, 'desc' => subject.desc}
      subject.to_h.should == hsh
    end
  end
  
  describe "#command" do
    it "creates a new command" do
      expect {
        subject.command(:comm)
      }.should change {subject.commands.size}.by(1)
    end
    
    it "resets the current description" do
      subject.desc 'A command'
      subject.command(:comm)
      subject.current_desc.should == ""
    end
  end
  
  describe "#switch" do
    it "creates a new switch" do
      expect {
        subject.switch(:s, :switch)
      }.should change {subject.switches.size}.by(1)
    end
    
    it "resets the current description" do
      subject.desc 'A switch'
      subject.switch(:s, :switch)
      subject.current_desc.should == ""
    end
  end
  
  describe "#flag" do
    it "creates a new flag" do
      expect {
        subject.flag(:f, :flag)
      }.should change {subject.flags.size}.by(1)
    end
    
    it "resets the current description" do
      subject.desc 'A flag'
      subject.flag(:f, :flag)
      subject.current_desc.should == ""
    end
  end
  
  describe "#bool" do
    it "creates two bool switches" do
      expect {
        subject.bool(:b, :bool)
      }.should change {subject.bools.size}.by(2)
    end
    
    it "resets the current description" do
      subject.desc 'A bool'
      subject.bool(:b, :bool)
      subject.current_desc.should == ""
    end
  end
  
  describe "#desc" do
    context "when called with no arguments" do
      it "returns the description for the command" do
        subject.desc.should == "A command"
      end
    end
    
    context "when called with an argument" do
      it "sets the current description" do
        subject.desc "A new desc"
        subject.instance_variable_get("@current_desc").should == "A new desc"
      end
    end
  end
  
  describe "#option_missing" do
    it "sets the option missing proc" do
      proc = lambda {|n| puts "What? #{name} doesn't exist" }
      subject.option_missing(&proc)
      subject.instance_variable_get("@option_missing").should == proc
    end
  end
  
  describe "#header" do
    it "sets the header" do
      subject.header "A header"
      subject.instance_variable_get("@header").should == "A header"
    end
  end
  
  describe "#footer" do
    it "sets the footer" do
      subject.footer "A footer"
      subject.instance_variable_get("@footer").should == "A footer"
    end
  end
  
  describe "#build_help" do
    it "adds a switch for help" do
      subject.options = []
      subject.options.should be_empty
      subject.build_help
      subject.options.map(&:names).should include ['h', 'help']
    end
  end
  
  describe "#help" do
    it "returns a string of help" do
      help = <<EOS
Usage: rspec co, comm [options]

  Options: 
    -h, --help                \e[90mDisplay help\e[0m
EOS
    
      subject.help.should == help
    end
  end
  
  describe "#help_formatter" do
    context "when called with a symbol" do
      it "uses the named formatter" do
        before = subject.instance_variable_get("@formatter")
        subject.help_formatter(:white)
        subject.instance_variable_get("@formatter").should_not == before
      end
    end
    
    context "when called with argumentss and a block" do
      it "creates a new help formatter" do
        subject.help_formatter :width => 40, :prepend => 5 do |h|
          h.switch  "switch"
          h.bool    "bool"
          h.flag    "flag"
          h.command "command"
        end
        formatter = subject.instance_variable_get("@formatter")
        formatter.width.should == 40
      end
    end
  end

end