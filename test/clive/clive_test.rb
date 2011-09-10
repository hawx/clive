$: << File.dirname(__FILE__) + '/..'
require 'helper'


class CliveTestClass
  extend Clive
  
  header 'Usage: clive_test.rb [command] [options]'
  
  opt :version, tail: true do
    puts "Version 1"
  end
  
  opt :a, :auto, as: Boolean
  opt :v, :verbose, as: Boolean
  
  opt :s, :size, 'Size of thing', arg: '<size>', as: Float
  opt :S, :super_size
    
  desc 'Print <message> <n> times'
  opt :print, arg: '<message> <n>', as: [String, Integer] do
    n.times { puts message }
  end
  
  opt :complex, :arg => '[<one>] <two> [<three>]', :match => [ /\d/, /\d\d/, /\d\d\d/ ] do |a,b,c|
    puts "a: #{a}, b: #{b}, c: #{c}"
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
  
  def test_calling_with_long_names
    a,s = CliveTestClass.run %w(--super-size)
    assert_equal({:super_size => true}, s)
  end
  
  def test_commands
    $stdout.expect(:puts, nil, ["Creating post in ~/my_site"])
    a,s = CliveTestClass.run %w(-v new --type post ~/my_site --no-auto arg)
    assert_equal %w(arg), a
    assert_equal({:verbose => true, :new => {:type => :post}, :auto => false}, s)
    $stdout.verify
  end
  
  def test_complex_arguments
    $stdout.expect(:puts, nil, ["a: 1, b: 22, c: 333"])
    a,s = CliveTestClass.run %w(--complex 1 22 333)
    $stdout.verify
    $stdout.reset
    
    $stdout.expect(:puts, nil, ["a: 1, b: 22, c: "])
    CliveTestClass.run %w(--complex 1 22)
    $stdout.verify
    $stdout.reset
    
    $stdout.expect(:puts, nil, ["a: , b: 22, c: 333"])
    CliveTestClass.run %w(--complex 22 333)
    $stdout.verify
    $stdout.reset
    
    $stdout.expect(:puts, nil, ["a: , b: 22, c: "])
    CliveTestClass.run %w(--complex 22)
    $stdout.verify
    $stdout.reset
    
    assert_raises Clive::Parser::MissingArgumentError do
      CliveTestClass.run %w(--complex 1)
    end
    
    assert_raises Clive::Parser::MissingArgumentError do
      CliveTestClass.run %w(--complex 333)
    end
  end
  
  def test_displays_help
    $stdout.expect(:puts, nil, [<<EOS])
Usage: clive_test.rb [command] [options]

  Commands:
    new <dir>                            # Creates new things
    help [<command>]                     # Display help

  Options:
    -a, --[no-]auto
    --complex [<one>] <two> [<three>]
    --print <message> <n>                # Print <message> <n> times
    -s, --size <size>                    # Size of thing
    -S, --super-size
    -v, --[no-]verbose
    -h, --help                           # Display this help message
    --version
EOS
    
    a,s = CliveTestClass.run %w(help)
    $stdout.verify
  end
  
end
