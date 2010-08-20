require 'helper'

class TestToken < Test::Unit::TestCase

  context "When converting" do
    setup do
      @array = ["add", "-al", "--verbose"]
      @array_split = ["add", "-a", "-l", "--verbose"]
      @tokens = [[:word, "add"], [:short, "a"], [:short, "l"], [:long, "verbose"]]
    end
  
    should "convert an array to tokens" do
      assert_equal @tokens, Clive::Tokens.to_tokens(@array)
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
    
    should "tell whether an array is a token" do
      t = Clive::Tokens.new
      assert_equal false, t.token?(["a", "normal", "array"])
      assert_equal true, t.token?([:word, "help"])
    end
    
    should "turn token to string" do
      t = Clive::Tokens.new
      assert_equal "-v", t.token_to_string([:short, "v"])
      assert_equal "--verbose", t.token_to_string([:long, "verbose"])
      assert_equal "word", t.token_to_string([:word, "word"])
    end
    
    should "add new string values" do
      t = Clive::Tokens.new
      t << "add" << "-al" << "--verbose"
      assert_equal @tokens, t.tokens
    end
    
    should "add new token values" do
      t = Clive::Tokens.new
      t << [:word, "add"] << [:short, "a"] << [:short, "l"] << [:long, "verbose"]
      assert_equal @array_split, t.array
    end
  
  end
  
end