require_relative 'helper'

class TestCommand < MiniTest::Unit::TestCase

  def setup
    @command = Clive::Command.new([:name], "A description", {})
  end

  def test_dsl
    @command.option :force, 'Forces building'
    assert @command.has_option?(:force)
    assert_equal 'Forces building', @command[:force].desc
    
    @command.desc 'The description for the next option'
    @command.opt :n, :next
    assert @command.has_option?(:n)
    assert @command.has_option?(:next)
    assert_equal 'The description for the next option', @command[:next].desc
  end
  
  def test_running
    a = nil
    c = Clive::Command.new([:name], "A description", {}) { a = 5 }
    c.run
    assert_equal 5, a
  end

end