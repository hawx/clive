require 'helper'

class TestSwitch < Test::Unit::TestCase
  
  context "A new switch" do
  
    setup do
      @c = Clive.new do
        switch(:d, :debug, "Use debug mode") {}
      end
    end
    
    should "create summary" do
      assert_equal "-d, --debug Use debug mode", @c.switches["d"].summary(0, 0)
    end
  
  end
end