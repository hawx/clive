$: << File.dirname(__FILE__) + '/..'
require 'helper'

describe Clive::Parser do

  describe 'help command' do
    subject { Clive.new(:name => '...') { command(:new) { opt :f, :force } } }

    describe 'with no argument' do
      it 'prints the help' do
        this {
          subject.run s 'help'
        }.must_output <<EOS
Usage: ... [command] [options]

  Commands:
    new
    help [<command>]      \e[90m# \e[0m\e[90mDisplay help\e[0m

  Options:
    -h, --help            \e[90m# \e[0m\e[90mDisplay this help message\e[0m
EOS
      end
    end

    describe 'with an argument' do
      it 'prints help for that command' do
        this {
          subject.run s 'help new'
        }.must_output <<EOS
Usage: ... new [options]

  Options:
    -f, --force
    -h, --help        \e[90m# \e[0m\e[90mDisplay this help message\e[0m
EOS
      end

      it 'prints an error if command does not exist' do
        this {
          subject.run s 'help missing'
        }.must_output "Error: command missing could not be found. Try `help` to see the available commands.\n"
      end
    end

  end

  describe 'single option' do
    subject {
      Clive.new {
        opt :force
      }
    }

    it 'runs the option' do
      r = subject.run s '--force'
      r.must_have :force
    end
  end

  describe 'single option with block' do
    subject {
      Clive.new {
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
      Clive.new {
        opt :name, :arg => '<name>'
      }
    }

    it 'runs the option' do
      r = subject.run s '--name "John Doe"'
      r.name.must_equal 'John Doe'
    end
  end

  describe 'single option with argument with block' do
    subject {
      Clive.new {
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
      Clive.new {
        opt :name, :arg => '<first> <last>'
      }
    }

    it 'runs the option' do
      r = subject.run s '--name John Doe'
      r.name.must_equal ['John', 'Doe']
    end
  end

  describe 'single option with arguments with block' do
    subject {
      Clive.new {
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
      Clive.new {
        bool :force
        bool :auto
      }
    }

    it 'runs the options' do
      r = subject.run s '--no-force --auto'
      r.wont_have :force
      r.must_have :auto
    end
  end

  describe 'Commands' do
    describe 'with options and arguments' do
      subject {
        Clive.new {
          command :new, :args => '<dir>' do
            bool :force
            opt :name, :arg => '<name>'
          end
        }
      }

      let(:result) { {:new => {:args => '~/somewhere', :force => true, :name => 'New'}} }

      it 'runs properly with arguments after options' do
        r = subject.run s 'new --force --name New ~/somewhere'
        r.must_equal result
      end

      it 'runs properly with options after arguments' do
        r = subject.run s 'new ~/somewhere --force --name New'
        r.must_equal result
      end

      it 'runs properly with arguments between options' do
        r = subject.run s 'new --force ~/somewhere --name New'
        r2 = subject.run s 'new --name New ~/somewhere --force'
        r2.must_equal r
        r2.args.must_equal r.args
        r.must_equal result
      end

      it 'runs properly with excessive arguemnts' do
        r = subject.run s 'new ~/somewhere Hello Other'
        r.new.args.must_equal '~/somewhere'
        r.args.must_equal ['Hello', 'Other']
      end
    end

    describe 'with options and optional arguments' do
      subject {
        Clive.new {
          command :new, :args => '[<dir>]' do
            bool :force
            opt :name, :arg => '<name>'
          end
        }
      }

      let(:result) { {:new => {:force => true, :name => 'New', :args => nil}} }
      let(:with_argument) { {:new => {:force => true, :name => 'New', :args => '~/somewhere'}} }

      it 'runs properly with just options' do
        r = subject.run s 'new --force --name New'
        r.must_equal result
      end

      it 'runs properly with arguments after options' do
        r = subject.run s 'new --force --name New ~/somewhere'
        r.must_equal with_argument
      end

      it 'runs properly with options after arguments' do
        r = subject.run s 'new ~/somewhere --force --name New'
        r.must_equal with_argument
      end

      it 'runs properly with arguments between options' do
        r = subject.run s 'new --force ~/somewhere --name New'
        r2 = subject.run s 'new --name New ~/somewhere --force'
        r2.must_equal r
        r2.args.must_equal r.args
        r.must_equal with_argument
      end

      it 'runs properly with excessive arguemnts' do
        r = subject.run s 'new ~/somewhere Hello Other'
        r[:new][:args].must_equal '~/somewhere'
        r.args.must_equal ['Hello', 'Other']
      end
    end
  end

end
