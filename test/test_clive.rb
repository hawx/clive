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
    assert_equal 2, c.switches.length # plus help
    assert_instance_of Clive::Switch, c.switches[0]
  end
  
  should "create command" do
    c = Clive.new do
      command(:add) {}
    end
    assert_equal 1, c.commands.length
    assert_instance_of Clive::Command, c.commands[0]
  end
  
  should "create boolean" do
    c = Clive.new do
      boolean(:verbose) {}
    end
    assert_equal 3, c.switches.length # plus help
    assert_instance_of Clive::Boolean, c.switches[0]
  end
  
  context "When parsing input" do
  
    should "recognise flags with equals" do
      opts = {}
      c = Clive.new do
        flag(:type) {|i| opts[:type] = i}
      end
      c.parse(["--type=big"])
      r = {:type => 'big'}
      assert_equal r, opts
    end
    
    should "recognise flags without equals" do
      opts = {}
      c = Clive.new do
        flag(:type) {|i| opts[:type] = i}
      end
      c.parse(["--type", "big"])
      r = {:type => 'big'}
      assert_equal r, opts
    end
    
    should "recongise short flags" do
      opts = {}
      c = Clive.new do
        flag(:t) {|i| opts[:type] = i}
      end
      c.parse(["-t", "big"])
      r = {:type => 'big'}
      assert_equal r, opts
    end
    
    should "recognise multiple flags" do
      opts = {}
      c = Clive.new do
        flag(:type) {|i| opts[:type] = i}
        flag(:lang) {|i| opts[:lang] = i}
        flag(:e) {|i| opts[:e] = i}
      end
      c.parse(["--type=big", "--lang", "eng", "-e", "true"])
      r = {:type => 'big', :lang => 'eng', :e => 'true'}
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
    
    should "recognise short switches" do
      opts = {}
      c = Clive.new do
        switch(:v, :verbose) {opts[:verbose] = true}
      end
      c.parse(["-v"])
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
    
    
    should "recognise commands" do
      opts = {}
      c = Clive.new do
        command(:add) {opts[:add] = true}
      end
      c.parse(["add"])
      r = {:add => true}
      assert_equal r, opts
    end
    
    should "recognise flags and switches within commands" do
      opts = {}
      c = Clive.new do
        command(:add) {
          opts[:add] = true
          
          switch(:v, :verbose) {opts[:verbose] = true}
          flag(:type) {|i| opts[:type] = i}
        }
      end
      c.parse(["add", "--verbose", "--type=big"])
      r = {:add => true, :verbose => true, :type => "big"}
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
    
    
    should "return unused arguments" do
      opts = {}
      c = Clive.new do
        switch(:v) {opts[:v] = true}
        flag(:h) {opts[:h] = true}
        command(:add) {
          switch(:full) {opts[:full] = true}
        }
      end
      result = c.parse(["-v", "add", "--full", "truearg"])
      assert_equal ["truearg"], result
    end
    
    should "return multiple unused arguments" do
      opts = {}
      c = Clive.new do
        switch(:v) {opts[:v] = true}
        flag(:h) {opts[:h] = true}
        command(:add) {
          switch(:full) {opts[:full] = true}
        }
      end
      result = c.parse(["-v", "onearg", "twoarg", "/usr/bin/env"])
      assert_equal ["onearg", "twoarg", "/usr/bin/env"], result
    end
    
  end
  
  
  context "When parsing ridiculous edge tests" do
  
    should "parse this crazy guy" do
      opts = {}
      c = Clive.new do
        switch(:v) {opts[:v] = true}
        flag(:h) {opts[:h] = true}
        
        command(:add) {
          opts[:add] = {}
          switch(:full) {opts[:add][:full] = true}
          flag(:breed) {|i| opts[:add][:breed] = i}
          
          command(:init) {
            opts[:add][:init] = {}
            switch(:base) {opts[:add][:init][:base] = true}
            flag(:name) {|i| opts[:add][:init][:name] = i}
          }
        }
      end
      c.parse(["-v", "add", "--full", "init", "--base", "--name=Works"])
      r = {:v => true, :add => {:full => true, :init => {:base => true, :name => 'Works'}} }
      assert_equal r, opts
    end
  
  end
  
end
