$: << File.dirname(__FILE__)

if RUBY_VERSION >= "1.9"
  require 'fileutils'
  require 'duvet'
  Duvet.start :filter => 'lib/clive'
end

require_relative '../lib/clive'

gem 'minitest'

require 'minitest/unit'
require 'minitest/mock'

require 'extras/red_green'
require 'extras/assertions/assert_argument'

module Kernel
  def d(*args)
    $_stdout.send(:puts, *args.map(&:inspect))
  end

  def duts(*args)
    $_stdout.send(:puts, *args.map(&:to_s))
  end

  def drint(*args)
    $_stdout.send(:print, *args)
  end
end

class MiniTest::Mock::StringIO
  def initialize
    reset
  end

  def reset
    @expect = {}
    @actual = Hash.new {|h,k| h[k] = [] }
  end

  # @param name [Symbol] Name of method expected
  # @param retval Value to return when +name+ is called
  # @param args [Array] Arguments expected
  def expect(name, retval, args=[])
    @expect[name] = {:retval => retval, :args => args}
  end

  def verify
    @expect.each_key do |name|
      expected = @expect[name]
      msg = "expected #{name}, #{expected.inspect}"
      raise MiniTest::Mock::MockExpectationError, msg unless
        @actual.has_key?(name) and @actual[name].include?(expected)
    end
    reset
    true
  end

  (StringIO.instance_methods - Object.instance_methods).each do |sym|
    class_eval <<-EOS
      def #{sym}(*args)
        if @expect.has_key?(:#{sym})
          r = @expect[:#{sym}][:retval]
          @actual[:#{sym}] << {:args => args, :retval => r}
          r
        end
      end
    EOS
  end
end

def reset_std
  $stdout.reset
  $stderr.reset
end

def flip_std
  $stdout, $_stdout = $_stdout, $stdout
  $stderr, $_stderr = $_stderr, $stderr
end

$_stdout = MiniTest::Mock::StringIO.new
$_stderr = MiniTest::Mock::StringIO.new

flip_std


require 'minitest/autorun'
