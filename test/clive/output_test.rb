$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Output do
  subject { Clive::Output }
  
  describe '#pad' do
    it 'pads a string to the right' do
      subject.pad('a', 5, '-').must_equal 'a----'
    end
    
    it 'ignores colour codes' do
      subject.pad('a'.red, 5,'-').must_equal 'a'.red + '----'
    end
    
    it 'returns the string if it exceeds the length' do
      subject.pad('abcdef', 5, '-').must_equal 'abcdef'
    end
  end
  
  describe '#wrap_text' do
    let(:text) { "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." }
    
    let :result do
      "Lorem ipsum dolor
      sit amet,
      consectetur
      adipisicing elit,
      sed do eiusmod
      tempor incididunt ut
      labore et dolore
      magna aliqua."
    end
    
    it 'wraps the text' do
      subject.wrap_text(text, 6, 26).must_equal result
    end
  end
  
  describe '#terminal_width' do
    it 'returns the width of the terminal' do
      ENV['COLUMNS'] = '80'
      subject.terminal_width.must_equal 80
    end
  end
  
end

describe String do

  describe '#colour' do
    it 'adds the correct escape codes' do
      "str".colour(5).must_equal "\e[5mstr\e[0m"
    end
    
    it 'adds multiple codes' do
      "str".l_red.bold.green_bg.blink.underline.must_equal "\e[4m\e[5m\e[42m\e[1m\e[91mstr\e[0m"
    end
  end
  
  describe '#clear_colours' do
    it 'removes all colour codes' do
      "str".red.blue_bg.bold.blink.clear_colours.must_equal "str"
    end
  end
  
  describe '#colour!' do
    it 'adds the correct escape codes' do
      s = "str"
      s.colour!(5)
      s.must_equal "\e[5mstr\e[0m"
    end
    
    it 'adds multiple codes' do
      s = "str"
      s.l_red!.bold!.green_bg!.blink!.underline!
      s.must_equal "\e[4m\e[5m\e[42m\e[1m\e[91mstr\e[0m"
    end
  end
  
  describe '#clear_colours!' do
    it 'removes all colours' do
      s = "str".red.green_bg.bold.blink
      s.clear_colours!
      s.must_equal "str"
    end
  end

end
