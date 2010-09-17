require 'helper'

class TestFlag < Test::Unit::TestCase
  
  context "A new flag" do
    
    setup do
      @c = Clive.new do
        flag(:t, :type, "TEXT", "Change type to TYPE") {|i| puts(i)}
      end
    end
    
    should "pass an argument to block" do
      mock($stdout).puts("text")
      @c.parse(["--type", "text"])
    end
    
    should "have a arguments" do
      r = {:name => "TEXT", :optional => false, :type => String}
      assert_equal r, @c.flags["t"].args[0]
    end
    
    should "not be optional" do
      assert_equal false, @c.flags["t"].args[0][:optional]
    end
  end
  
  context "A new flag with default" do
  
    setup do
      @c = Clive.new do
        flag(:t, :type, "[TEXT]", "Change type to TYPE") do |i| 
          i ||= 'dog'
          $stdout.puts(i)
        end
      end
    end
    
    should "have an arg name" do
      r = {:name => "TEXT", :optional => true, :type => String}
      assert_equal r, @c.flags["t"].args[0]
    end
    
    should "be optional" do
      assert_equal true, @c.flags["t"].args[0][:optional]
    end
    
    should "pass an argument to block" do
      mock($stdout).puts("text")
      @c.parse(["--type", "text"])
    end
    
    should "pass nil to the block if no argument" do
      mock($stdout).puts("dog")
      @c.parse(["--type"])
    end
  end
  
  context "A new flag with multiple arguments" do
    
    setup do
      @c = Clive.new do
        flag(:s, :send, "FROM TO", "Send the message from FROM to TO") do |from, to|
          puts from
          puts to
        end
      end
    end 
    
    should "pass two arguments to the block" do
      mock($stdout).puts("John")
      mock($stdout).puts("Dave")
      @c.parse(["--send", "John", "Dave"])
    end
    
    should "have a useful summary" do
      s = "-s, --send FROM TO Send the message from FROM to TO"
      assert_equal s, @c.flags['s'].summary(0, 0)
    end
  end
  
  context "A new flag with a list of acceptable arguments" do
    
    setup do
      @c = Clive.new do
        flag(:t, :type, ["large", "medium", "small"], "Choose the type to use") {}
      end
    end
    
    should "raise error when correct argument not found" do
      #flunk
    end
    
    should "make list arguments" do
      r = ["large", "medium", "small"]
      assert_equal r, @c.flags['t'].args
    end
    
    should "have a useful summary" do
      s = "-t, --type {large, medium, small} Choose the type to use"
      assert_equal s, @c.flags['t'].summary(0, 0)
    end
  end
end