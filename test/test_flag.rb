require 'helper'

class TestFlag < Test::Unit::TestCase
  
  context "A new flag" do
    
    setup do
      @c = Clive.new do
        flag(:t, :type, "TEXT", "Change type to TYPE") {|i| $stdout.puts(i)}
      end
    end
    
    should "pass an argument to block" do
      mock($stdout).puts("text")
      @c.parse(["--type", "text"])
    end
    
    should "have an arg name" do
      assert_equal "TEXT", @c.flags["t"].arg_name
    end
    
    should "not be optional" do
      assert_equal false, @c.flags["t"].optional
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
      assert_equal "TEXT", @c.flags["t"].arg_name
    end
    
    should "be optional" do
      assert_equal true, @c.flags["t"].optional
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
  
end