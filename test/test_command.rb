require 'helper'

class TestCommand < Test::Unit::TestCase

  context "A new command" do
  
    setup do
      @c = Clive.new do
        command(:add, "Add something") {puts "called!"}
      end
    end
    
    context "with multiple names" do
      setup do
        @c = Clive.new do
          command(:add, :init, :new, "Add something") {puts "called!"}
        end
      end
      
      should "be called with first name" do
        mock($stdout).puts("called!")
        @c.parse ["add"]
      end
      
      should "be called with second name" do
        mock($stdout).puts("called!")
        @c.parse ["init"]
      end
      
      should "be called with third name" do
        mock($stdout).puts("called!")
        @c.parse ["new"]
      end
    end
  
  
    should "only execute it's block when called" do
      mock($stdout).puts("called!")
      @c.parse(["a"])
      @c.parse(["add"])
    end
  
  end 
end