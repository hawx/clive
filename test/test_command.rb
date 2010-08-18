require 'helper'

class TestCommand < Test::Unit::TestCase

  context "A new command" do
  
    setup do
      @c = Clive.new do
        command(:add, "Add something") {puts "called!"}
      end
    end
  
  
    should "only execute it's block when called" do
      mock($stdout).puts("called!")
      @c.parse(["a"])
      @c.parse(["add"])
    end
    
    context "when run" do
    
    end
  
  end
end