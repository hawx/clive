require 'helper'

class TestClive < Test::Unit::TestCase
  
  should "create flag" do
    c = Clive.new do
      flag(:v) {}
    end
    assert_equal 1, c.flags.length
    assert_instance_of Clive::Flag, c.flags[0]
  end
  
  should "create switch" do
    c = Clive.new do
      switch(:v) {}
    end
    assert_equal 1, c.switches.length
    assert_instance_of Clive::Switch, c.switches[0]
  end
  
  should "create command" do
    c = Clive.new do
      command(:add) {}
    end
    assert_equal 1, c.commands.length
    assert_instance_of Clive::Command, c.commands[0]
  end
  
  context "When parsing input" do
  
    should "recognise flags" do
      opts = {}
      c = Clive.new do
        flag(:type) {|i| opts[:type] = i}
      end
      c.parse(["--type=big"])
      r = {:type => 'big'}
      assert_equal r, opts
    end
    
    should "recognise multiple flags" do
      opts = {}
      c = Clive.new do
        flag(:type) {|i| opts[:type] = i}
        flag(:lang) {|i| opts[:lang] = i}
      end
      c.parse(["--type=big", "--lang", "eng"])
      r = {:type => 'big', :lang => 'eng'}
      assert_equal r, opts
    end
    
    
    should "recognise switches" do
      opts = {}
      c = Clive.new do
        switch(:v, :verbose) {opts[:verbose] = true}
      end
      c.parse(["--verbose"])
      r = {:verbose => true}
      assert_equal r, opts
    end
    
    should "recognise multiple switches" do
      opts = {}
      c = Clive.new do
        switch(:v, :verbose) {opts[:verbose] = true}
        switch(:r, :recursive) {opts[:recursive] = true}
      end
      c.parse(["--verbose", "-r"])
      r = {:verbose => true, :recursive => true}
      assert_equal r, opts
    end
    
    should "recognise multiple combined short switches" do
      opts = {}
      c = Clive.new do
        switch(:v, :verbose) {opts[:verbose] = true}
        switch(:r, :recursive) {opts[:recursive] = true}
      end
      c.parse(["-vr"])
      r = {:verbose => true, :recursive => true}
      assert_equal r, opts
    end
    
    
    should "parse a mixture properly" do
      opts = {}
      c = Clive.new do
        switch(:v) {opts[:v] = true}
        flag(:h) {opts[:h] = true}
        command(:add) {
          switch(:full) {opts[:full] = true}
        }
      end
      c.parse(["-v", "add", "--full"])
      r = {:v => true, :full => true}
      assert_equal r, opts
    end
    
  end
  
end
