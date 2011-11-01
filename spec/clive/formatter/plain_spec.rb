$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Formatter::Plain do

  let :clive do
    Class.new {
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
    }
  end
  
  subject { Clive::Formatter::Plain }
  
  describe '#to_s' do
    
    it 'builds the help string' do
      this {
        clive.run s('help'), :formatter => subject.new(:width => 80)
      }.must_output <<EOS
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
    end
    
    it 'obeys minimum ratio' do
      this {
        clive.run s('help'), :formatter => subject.new(:width => 80, :min_ratio => 0.7)
      }.must_output r = <<EOS
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
            
            
    end
    
    it 'obeys the maximum ratio' do
      this {
        clive.run s('help'), :formatter => subject.new(:width => 80, :min_ratio => 0, :max_ratio => 0.3)
      }.must_output <<EOS
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
    end
    
  end
end
