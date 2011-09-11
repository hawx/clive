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
  
  def test_allows_access_to_arguments_by_name
    assert_output "1\n" do
      subject._run({:a => 1}, {}, proc { puts a })
    end
  end

end