require 'helper'

class TestBoolean < Test::Unit::TestCase
  
  context "A new boolean switch" do
  
    setup do
      @c = Clive.new do
        boolean(:v, :verbose, "Run verbosely") {|i| puts(i)}
      end
    end
  
    should "create two switches" do
      assert_equal 2, @c.booleans.length
    end
    
    should "raise error when no long name given" do
      assert_raise Clive::Boolean::NoLongName do
        Clive::Boolean.new(:v, "Run verbosely") {}
      end
    end
    
    context "the true switch" do
      should "have a short name" do
        assert_contains @c.booleans["verbose"].names, "v"
      end
      
      should "pass true to the block" do
        mock($stdout).puts(true)
        @c.parse(["--verbose"])
      end
      
      should "create summary" do
        assert_equal "-v, --[no-]verbose Run verbosely", @c.booleans["verbose"].summary(0, 0)
      end
    end
    
    context "the false switch" do
      should "not have short name" do
        assert_does_not_contain @c.booleans["no-verbose"].names, "v"
      end
      
      should "pass false to the block" do
        mock($stdout).puts(false)
        @c.parse(["--no-verbose"])
      end
      
      should "not create summary" do
        assert_equal nil, @c.booleans["no-verbose"].summary
      end
    end
  
  end
  
end