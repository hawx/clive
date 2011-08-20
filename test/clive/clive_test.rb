$: << File.dirname(__FILE__) + '..'
require 'helper'
=begin
class CliveTestClass
  include Clive
  
  opt :version, tail: true do
    puts "Version 1"
  end
  
  opt :a, :auto, as: Boolean
  opt :v, :verbose, as: Boolean
  
  opt :s, :size, 'Size of thing', arg: '<size>', as: Float
  
  desc 'Print <message> <n> times'
  opt :print, arg: '<message> <n>', as: [String, Integer] do
    n.times { puts message }
  end
  
  command :new, 'Creates new things', arg: '<dir>' do

    # implicit arg as "<choice>", also added default
    opt :type, in: %w(post page blog), default: :page, as: Symbol
    opt :force, 'Force overwrite' do
      require 'highline/import'
      answer = ask("Are you sure, this could delete stuff? [y/n]\n")
      set :force, true if answer == "y"
    end
  
    action do |dir|
      puts "Creating #{get :type} in #{dir}"
    end
  end
end

class TestClive < MiniTest::Unit::TestCase

  def test_boolean_switches
    a,s = CliveTestClass.run %w(--no-auto -v)
    assert_equal({:auto => false, :verbose => true}, s)
  end
  
  def test_combined_short_switches
    a,s = CliveTestClass.run %w(-vas 2.45)
    assert_equal({:verbose => true, :auto => true, :size => 2.45}, s)
    
    assert_raises Clive::Parser::MissingArgumentError do
      CliveTestClass.run %w(-vsa 2.45)
    end
  end
  
  def test_commands
    reset_std
    $stdout.expect(:puts, nil, ["Creating post in ~/my_site"])
    a,s = CliveTestClass.run %w(-v new --type post ~/my_site --no-auto arg)
    assert_equal %w(arg), a
    assert_equal({:verbose => true, :new => {:type => :post}, :auto => false}, s)
    $stdout.verify
  end

end
=end