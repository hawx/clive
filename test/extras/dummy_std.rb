# Stop #puts, #p, #print and #warn from outputting text, instead save the
# calls in a special mock object which can have expectation placed
# on it which can be verified.
#

class MiniTest::Mock::StringIO
  def initialize
    reset
  end
  
  def reset
    @expect = {}
    @actual = Hash.new {|h,k| h[k] = [] }
  end
  
  def calls
    @actual
  end
  
  # @param name [Symbol] Name of method expected
  # @param retval Value to return when +name+ is called
  # @param args [Array] Arguments expected
  def expect(name, retval, args=[])
    @expect[name] = {:retval => retval, :args => args}
  end
  
  include MiniTest::Assertions

  def verify
    @expect.each_key do |name|
      expected = @expect[name]
      
      if @actual[name]
        msg = diff(expected[:args][0], @actual[name][0][:args][0])
      else
        msg = "expected #{name} with, \n\n" + expected[:args][0].to_s
      end
        
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

$stdout, $_stdout = MiniTest::Mock::StringIO.new, $stdout
$stderr, $_stderr = MiniTest::Mock::StringIO.new, $stderr

MiniTest::Unit.before_each_test {
  $stdout.reset
  $stderr.reset
}

# Then add new debugging output methods which can be used sparingly but
# warn of their existence so you don't accidentally release them.
#
module Kernel
  def d(*o)
    $_stdout.send(:puts, *o.map {|i| i.inspect })
  end
  
  def duts(*o)
    $_stdout.send(:puts, *o.map {|i| i.to_s })
  end
  
  def drint(*o)
    $_stdout.send(:print, *o)
  end
end
