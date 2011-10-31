$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Parser do
  
  describe 'single option' do
    subject {
      Class.new { extend Clive
        opt :force
      }
    }
    
    it 'runs the option' do
      a,s = subject.run s '--force'
      s[:force].must_be_true
    end
  end
  
  describe 'single option with block' do
    subject {
      Class.new { extend Clive
        opt(:force) { print "forced" }
      }
    }
    
    it 'runs the option' do
      this {
        subject.run s '--force'
      }.must_output "forced"
    end
  end
  
  describe 'single option with argument' do
    subject {
      Class.new { extend Clive
        opt :name, :arg => '<name>'
      }
    }
    
    it 'runs the option' do
      a,s = subject.run s '--name "John Doe"'
      s[:name].must_equal 'John Doe'
    end
  end
  
  describe 'single option with argument with block' do
    subject {
      Class.new { extend Clive
        opt(:name, :arg => '<name>') {|name| print "I am #{name}" }
      }
    }
    
    it 'runs the option' do
      this {
        subject.run s '--name "John Doe"'
      }.must_output "I am John Doe"
    end
  end
  
  describe 'single option with arguments' do
    subject {
      Class.new { extend Clive
        opt :name, :arg => '<first> <last>'
      }
    }
    
    it 'runs the option' do
      a,s = subject.run s '--name John Doe'
      s[:name].must_equal ['John', 'Doe']
    end
  end
  
  describe 'single option with arguments with block' do
    subject {
      Class.new { extend Clive
        opt(:name, :arg => '<first> <last>') { print "I am #{first} #{last}" }
      }
    }
    
    it 'runs the option' do
      this {
        subject.run s '--name John Doe'
      }.must_output "I am John Doe"
    end
  end
  
  describe 'Boolean options' do
    subject {
      Class.new { extend Clive
        bool :force
        bool :auto
      }
    }
    
    it 'runs the options' do
      a,s = subject.run s '--no-force --auto'
      s[:force].must_be_false
      s[:auto].must_be_true
    end
  end
  
  describe 'Commands' do  
    describe 'with options and arguments' do
      subject {
        Class.new { extend Clive
          command :new, :args => '<dir>' do
            bool :force
            opt :name, :arg => '<name>'
          end
        }
      }
      
      let(:result) { {:new => {:args => '~/somewhere', :force => true, :name => 'New'}} }
      
      it 'runs properly with arguments after options' do
        a,s = subject.run s 'new --force --name New ~/somewhere'
        s.must_equal result
      end
      
      it 'runs properly with options after arguments' do
        a,s = subject.run s 'new ~/somewhere --force --name New'
        s.must_equal result
      end
      
      it 'runs properly with arguments between options' do
        a,s = subject.run s 'new --force ~/somewhere --name New'
        a2,s2 = subject.run s 'new --name New ~/somewhere --force'
        a2.must_equal a
        s2.must_equal s
        s.must_equal result
      end
      
      it 'runs properly with excessive arguemnts' do
        a,s = subject.run s 'new ~/somewhere Hello Other'
        s[:new][:args].must_equal '~/somewhere'
        a.must_equal ['Hello', 'Other']
      end
    end
    
    describe 'with options and optional arguments' do
      subject {
        Class.new { extend Clive
          command :new, :args => '[<dir>]' do
            bool :force
            opt :name, :arg => '<name>'
          end
        }
      }
      
      let(:result) { {:new => {:force => true, :name => 'New', :args => nil}} }
      let(:with_argument) { {:new => {:force => true, :name => 'New', :args => '~/somewhere'}} }
      
      it 'runs properly with just options' do
        a,s = subject.run s 'new --force --name New'
        s.must_equal result
      end
      
      it 'runs properly with arguments after options' do
        a,s = subject.run s 'new --force --name New ~/somewhere'
        s.must_equal with_argument
      end

      it 'runs properly with options after arguments' do
        a,s = subject.run s 'new ~/somewhere --force --name New'
        s.must_equal with_argument
      end
      
      it 'runs properly with arguments between options' do
        a,s = subject.run s 'new --force ~/somewhere --name New'
        a2,s2 = subject.run s 'new --name New ~/somewhere --force'
        a2.must_equal a
        s2.must_equal s
        s.must_equal with_argument
      end
      
      it 'runs properly with excessive arguemnts' do
        a,s = subject.run s 'new ~/somewhere Hello Other'
        s[:new][:args].must_equal '~/somewhere'
        a.must_equal ['Hello', 'Other']
      end
    end
  end
  
end
