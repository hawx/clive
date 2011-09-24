$: << File.dirname(__FILE__) + '/..'
require 'helper'


class CliveTestClass2
  extend Clive
  
  header 'Usage: clive_test.rb [command] [options]'
  footer 'Further help is available online'
  
  opt :version, :tail => true
  
  opt :S, :super_size, :head => true
  bool :a, :auto
  opt :s, :size, 'Size of thing', :arg => '<size>'
  
  
  desc 'A super long description for a super stupid option, this should test the _extreme_ wrapping abilities as it should all be aligned. Maybe I should go for another couple of lines just for good measure. That\'s all'
  opt :complex, :arg => '[<one>] <two> [<three>]'
  
  command :new, 'Creates new things', :arg => '<dir>' do
    opt :type, :in => %w(post page blog), :default => :page
    opt :force, 'Force overwrite'
  end

end


class FormatterTest < MiniTest::Unit::TestCase

  def test_builds_help_string
    r = <<EOS
Usage: clive_test.rb [command] [options]

  Commands:
    new <dir>                             # Creates new things
    help [<command>]                      # Display help

  Options:
    -S, --super-size
    -a, --[no-]auto
    --complex [<one>] <two> [<three>]     # A super long description for a
                                            super stupid option, this should
                                            test the _extreme_ wrapping
                                            abilities as it should all be
                                            aligned. Maybe I should go for
                                            another couple of lines just for
                                            good measure. That's all
    -s, --size <size>                     # Size of thing
    -h, --help                            # Display this help message
    --version

Further help is available online
EOS

    assert_output r do
      CliveTestClass2.run s('help'), :formatter => Clive::Formatter.new(80)
    end
  end
  
  def test_help_string_obeys_minimum_ratio
#------------------------------------------------------------------------------| 80
#                                                       |======================| 24
    r = <<EOS
Usage: clive_test.rb [command] [options]

  Commands:
    new <dir>                                             # Creates new things
    help [<command>]                                      # Display help

  Options:
    -S, --super-size
    -a, --[no-]auto
    --complex [<one>] <two> [<three>]                     # A super long
                                                            description for a
                                                            super stupid option,
                                                            this should test the
                                                            _extreme_ wrapping
                                                            abilities as it
                                                            should all be
                                                            aligned. Maybe I
                                                            should go for
                                                            another couple of
                                                            lines just for good
                                                            measure. That's all
    -s, --size <size>                                     # Size of thing
    -h, --help                                            # Display this help
                                                            message
    --version

Further help is available online
EOS
#------------------------------------------------------------------------------| 80
#                                                       |======================| 24
    
    assert_output r do
      CliveTestClass2.run s('help'), :formatter => Clive::Formatter.new(80, 2, 0.7)
    end
  end
  
  def test_help_string_obeys_maximum_ratio
  
#------------------------------------------------------------------------------| 80
#======================|24#
    r = <<EOS
Usage: clive_test.rb [command] [options]

  Commands:
    new <dir>             # Creates new things
    help [<command>]      # Display help

  Options:
    -S, --super-size
    -a, --[no-]auto
    --complex
       [<one>] <two>
       [<three>]          # A super long description for a super stupid option,
                            this should test the _extreme_ wrapping abilities as
                            it should all be aligned. Maybe I should go for
                            another couple of lines just for good measure.
                            That's all
    -s, --size <size>     # Size of thing
    -h, --help            # Display this help message
    --version

Further help is available online
EOS
#======================|  #
#------------------------------------------------------------------------------|

    assert_output r do
      CliveTestClass2.run s('help'), :formatter => Clive::Formatter.new(80, 2, 0, 0.3)
    end
  end

end