$: << File.dirname(__FILE__) + '/..'
require 'helper'

class TestCommand < MiniTest::Unit::TestCase

  def setup
    @command = Clive::Command.new([:name], "A description", {})
  end

  def test_dsl
    @command.option :force, 'Forces building'
    assert @command.has_option?(:force)
    assert_equal 'Forces building', @command.find_option(:force).desc
    
    @command.desc 'The description for the next option'
    @command.opt :n, :next
    assert @command.has_option?(:n)
    assert @command.has_option?(:next)
    assert_equal 'The description for the next option', @command.find_option(:next).desc
  end
  
  def test_running
    a = nil
    c = Clive::Command.new([:name], "A description", {}) { a = 5 }
    c.run_block
    assert_equal 5, a
  end
  
  def test_can_have_arguments
    command = Clive::Command.new([:new], 'New stuff', {:arg => '<place>'}) do
      action do |place|
        puts place
      end
    end
    
    command.run_block
    assert_output "hey\n" do
      command.run({}, ['hey'])
    end
  end
  
  def test_arguments_work
    command = Clive::Command.new([:new], "", {:arg => '<dir>'})
    
    state = {}
    command.run(state, %w(~/somewhere))
    assert_equal({:args => '~/somewhere'}, state)
  end

end