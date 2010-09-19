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
    
    should "work for more than two arguments" do
      mock($stdout).puts("from: Josh, to: John, via: Hong Kong, because: It's far away")
      c = Clive.new do
        flag(:s, :send, "FROM TO VIA BECAUSE", "Send the message...etc") do |f, t, v, b|
          puts "from: #{f}, to: #{t}, via: #{v}, because: #{b}"
        end
      end
      c.parse ['-s', 'Josh', 'John', "Hong Kong", "It's far away"]
    end
    
    context "and optional arguments" do
      setup do
        @c = Clive.new do
          flag(:s, :send, "FROM [VIA] TO [BECAUSE]", "Send the message...etc") do |f, v, t, b|
            s = "from: #{f}"
            s << ", via: #{v}" if v
            s << ", to: #{t}"
            s << ", because: #{b}" if b
            puts s
          end
        end
      end
      
      should "correctly parse argument string" do
        r = [
          {:name => "FROM",    :optional => false, :type => String},
          {:name => "VIA",     :optional => true,  :type => String},
          {:name => "TO",      :optional => false, :type => String},
          {:name => "BECAUSE", :optional => true,  :type => String}
        ]
        assert_equal r, @c.flags[:s].args
      end
      
      should "give all arguments when found in input" do
        mock($stdout).puts("from: Josh, via: Hong Kong, to: John, because: It's far away")
        @c.parse ["-s", "Josh", "Hong Kong", "John", "It's far away"]
      end
      
      should "try to give only needed arguments if some missing" do
        mock($stdout).puts("from: Josh, to: John")
        @c.parse ["-s", "Josh", "John"]
      end
      
      should "fill optional arguments starting from left" do
        mock($stdout).puts("from: Josh, via: Hong Kong, to: John")
        @c.parse ["-s", "Josh", "Hong Kong", "John"]
      end
      
    end
  end
  
  context "A new flag with a list of acceptable arguments" do
    
    setup do
      @c = Clive.new do
        flag(:t, :type, ["large", "medium", "small"], "Choose the type to use") {}
      end
    end
    
    should "raise error when correct argument not found" do
      assert_raise Clive::InvalidArgument do
        @c.parse(["--type", "apple"])
      end
    end
    
    should "not raise error when correct argument given" do
      @c.parse(["--type", "large"])
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