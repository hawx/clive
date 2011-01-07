require 'spec_helper'

describe Clive::Formatter do

  describe Clive::Formatter::Obj do
    subject { Clive::Formatter::Obj.new({:test => 5}) }
    
    describe "#initialize" do
      it "defines methods given by hash" do
        subject.test.should == 5
      end
    end
    
    describe "#evaluate" do
      it "evaluates code within the object" do
        $stdout.should_receive(:puts).with(5)
        subject.evaluate("$stdout.puts test")
      end
    end
  end
  
  
  subject { Clive::Formatter.new(30, 5) }
  
  
  describe "#switch" do
    it "sets format for switches" do
      subject.switch("{desc}")
      subject.instance_variable_get("@switch").should == "{desc}"
    end
  end
  
  describe "#bool" do
    it "sets format for bools" do
      subject.bool "{desc}"
      subject.instance_variable_get("@bool").should == "{desc}"
    end
  end
  
  describe "#flag" do
    it "sets format for flags" do
      subject.flag "{desc}"
      subject.instance_variable_get("@flag").should == "{desc}"
    end
  end
  
  describe "#command" do
    it "sets format for commands" do
      subject.command "{desc}"
      subject.instance_variable_get("@command").should == "{desc}"
    end
  end
  
  
  describe "#format" do
    it "generates the help" do
      formatter = Clive::Command.new(true).help_formatter(:white)
      options = [
        Clive::Switch.new([:t, :test], "A test switch"),
        Clive::Bool.new([:boolean], "A bool", true),
        Clive::Bool.new([:boolean], "A bool", false),
        Clive::Flag.new([:args], "With args", ["ARG [OPT]"]),
        Clive::Flag.new([:choose], "With options", [["a", "b", "c"]])
      ]
      command = Clive::Command.new([:command], "A command")
      result = <<EOS
head

  Commands: 
     command                  A command

  Options: 
     -t, --test               A test switch
     --[no-]boolean           A bool
     --args ARG [OPT]         With args \e[1m\e[0m
     --choose                 With options \e[1m(a, b, c)\e[0m

foot
EOS
      
      formatter.format("head", "foot", [command], options).should == result
    end
  end
  
  
  describe "#parse" do
    it "parses before and after '{spaces}' separately" do
      args = {"name" => "a", "desc" => "something"}
      subject.should_receive(:parse_format).with("{name}", args).and_return("")
      subject.should_receive(:parse_format).with("{desc}", args).and_return("")
      subject.parse("{name}{spaces}{desc}", args)
    end
    
    it "calculates the correct number of spaces" do
      args = {"name" => "a long name", "desc" => "|a short desc"}
      subject.parse("{name}{spaces}{desc}", args).split('|')[0].size.should == 30
    end
  end
  
  describe "#parse_format" do
    it "inserts the arguments into the format" do
      subject.parse_format(
        "{desc}{name}", {'desc' => 'a', 'name' => 'b'}
      ).should == "ab"
    end
  end

end