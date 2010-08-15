require 'helper'

class TestClive < Test::Unit::TestCase
  
  context "When given bad input" do
  
    should "warn of missing arguments" do
      c = Clive.new do
        flag(:hello) {}
      end
      assert_raise Clive::MissingArgument do
        c.parse(["--hello"])
      end
    end
    
    should "warn of invalid options" do
      c = Clive.new do
        switch(:hello) {}
      end
      assert_raise Clive::InvalidOption do
        c.parse(["--what"])
      end
    end
  
  
  end
  
end