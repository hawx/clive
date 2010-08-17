require 'helper'

class TestToken < Test::Unit::TestCase

  context "When converting" do
    setup do
      @array = ["add", "-al", "--verbose"]
      @array_split = ["add", "-a", "-l", "--verbose"]
      @tokens = [[:word, "add"], [:short, "a"], [:short, "l"], [:long, "verbose"]]
    end
  
    should "convert an array to tokens" do
      t = Clive::Tokens.new(@array)
      assert_equal @tokens, t.tokens
    end
    
    should "convert tokens to an array" do
      assert_equal @array_split, Clive::Tokens.to_array(@tokens)
    end  
  end
  
  context "A new tokens instance" do
  
    setup do
      @array = ["add", "-al", "--verbose"]
      @array_split = ["add", "-a", "-l", "--verbose"]
      @tokens = [[:word, "add"], [:short, "a"], [:short, "l"], [:long, "verbose"]]
      
      @t = Clive::Tokens.new
      @t << "add" << "-al" << "--verbose"
    end
    
    should "be created from an array" do
      t = Clive::Tokens.new(@tokens)
      assert_equal @tokens, t.tokens
      assert_equal @array_split, t.array
    end
    
    should "be created from tokens" do
      t = Clive::Tokens.new(@array)
      assert_equal @tokens, t.tokens
      assert_equal @array_split, t.array
    end
  
    should "have tokens" do
      
    end
    
    should "have an array" do
    
    end
  
  end
  
end