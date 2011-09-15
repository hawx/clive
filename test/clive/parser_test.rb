$: << File.dirname(__FILE__) + '/..'
require 'helper'

class TestParser < MiniTest::Unit::TestCase
  extend Clive::Type::Lookup
  # this is a bit of a hack, it seems I can't redefine .const_missing in a block
  # so this is what I have to do.

  def test_parsing_with_normal_blocks
    a = nil
    base = Class.new { include Clive
      opt :force do
        a = "forced"
      end
    }
    base.run s('--force')
    assert_equal "forced", a
  end

  def test_parsing_with_arguments_for_options
    a = nil
    base = Class.new { include Clive
      opt :name, :arg => '<name>' do |name|
        a = name
      end
    }
    base.run s('--name John')
    assert_equal "John", a
  end

  def test_parsing_with_automatic_blocks
    base = Class.new { include Clive; opt :force }

    args, state = base.run s('--force hey')
    assert_equal %w(hey), args
    assert_equal({:force => true}, state)
  end

  def test_parsing_with_automatic_blocks_and_arguments
    base = Class.new { include Clive; opt :name, :arg => '<name>' }

    args, state = base.run s('--name John')
    assert_equal [], args
    assert_equal({:name => 'John'}, state)
  end

  def test_no_parsing
    a = nil

    base = Class.new { include Clive
      opt :force, :as => Boolean
      opt :auto, :as => Boolean do |truth|
        a = truth
      end
    }

    args, state = base.run s('--no-force --no-auto')
    assert_equal({:force => false}, state)
    assert_equal false, a
  end

  def test_parsing_command_with_opts_after_args
    a = nil
    base = Class.new { include Clive

      command :new, :args => '<dir>' do
        opt :force, :as => Boolean

        action do |dir|
          a = dir
        end
      end
    }

    args, state = base.run s('new ~/somewhere --force')
    assert_equal({:new => {:force  => true}}, state)
    assert_equal [], args
    assert_equal "~/somewhere", a
  end

end
