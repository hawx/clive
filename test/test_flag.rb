require 'helper'

class TestFlag < Test::Unit::TestCase
  
  context "A new flag" do
    
    setup do
      @c = Clive.new do
        flag(:t, :type, "Choose type") {|i| $stdout.puts(i)}
      end
    end
    
    should "pass an argument to block" do
      mock($stdout).puts("text")
      @c.parse(["--type", "text"])
    end
    
  end
end