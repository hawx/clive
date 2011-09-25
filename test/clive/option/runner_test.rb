$: << File.dirname(__FILE__) + '/../..'
require 'helper'

class RunnerTest < MiniTest::Unit::TestCase

  def subject
    Clive::Option::Runner
  end

  def test_runs_function_within_class
    assert_output "Clive::Option::Runner\n" do
      subject._run({}, {}, proc { puts self.name })
    end
  end
  
  def test_allows_getting_items_from_state
    assert_output "1\n" do
      subject._run({}, {:a => 1}, proc { puts get(:a) })
    end
  end
  
  def test_allows_setting_items_in_state
    state = {}
    subject._run({}, state, proc { set(:a, 1) })
    assert_equal 1, state[:a]
  end
  
  def test_allows_updating_items_in_state
    state = {}
    subject._run({}, state, proc { 
      set(:name, "John Doe") unless has?(:name)
      update(:name, :upcase) 
    })
    assert_equal "JOHN DOE", state[:name]
  end
  
  def test_allows_updating_items_in_state_with_value
    state = {}
    subject._run({}, state, proc { 
      set(:list, []) unless has?(:list)
      update(:list, :<<, 1) 
    })
    assert_equal [1], state[:list]
    
    state = {}
    subject._run({}, state, proc {
      set(:line, "A man a plan a canal") unless has?(:line)
      update :line, :gsub, /[Aa]/, 'i'
    })
    assert_equal "i min i plin i cinil", state[:line]
  end
  
  def test_allows_updating_items_with_block_in_state
    state = {}
    subject._run({}, state, proc {
      update(:list) {|l| (l ||= []) << 1 }
    })
    assert_equal [1], state[:list]
  end
  
  def test_update_raises_error_with_missing_arguments
    assert_raises ArgumentError do
      subject._run({}, {}, proc { update(:a) })
    end
  end
  
 # opt :add do |item|
 #   set :list, [] if has? :list
 #   update :list, :<<, item
 #   #update(:list) {|l| (l ||= []) << item }
 # end
  
  def test_allows_access_to_arguments_by_name
    assert_output "1\n" do
      subject._run({:a => 1}, {}, proc { puts a })
    end
  end

end