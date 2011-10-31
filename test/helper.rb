$: << File.dirname(__FILE__) + '/..'

if RUBY_VERSION >= "1.9"
  require 'fileutils'
  begin
    require 'duvet'
    Duvet.start :filter => 'lib/clive'
  rescue LoadError
    # it doesn't really matter
  end
end

require 'lib/clive'
require 'rubygems'
require 'shellwords'

def s(str)
  Shellwords.split(str)
end

gem 'minitest'
require 'minitest/unit'
require 'minitest/spec'
require 'minitest/mock'
require 'minitest/autorun'

module MiniTest::Expectations
  # a.must_have :key?, :yay
  alias_method :must_have, :must_be
  # a.wont_have :key?, :boo
  alias_method :wont_have, :wont_be
  # this { ... }.must_raise ExceptionalException
  alias_method :this, :proc
  
  # true.must_be_true
  infect_an_assertion :assert, :must_be_true
  # true.wont_be_false
  alias_method :wont_be_false, :must_be_true
  
  # false.must_be_false
  infect_an_assertion :refute, :must_be_false
  # false.wont_be_true
  alias_method :wont_be_true, :must_be_false
  
  # @example
  #   arg.must_be_argument :name => :arg, :optional => true, :type => Integer
  #
  def must_be_argument(opts)
    opts.each do |k,v|
      self.instance_variable_get("@#{k}").must_equal v
    end
  end
end

# > FOCUS=true bundler exec rake
FOCUS_MODE = ENV['FOCUS'] == 'true'

class MiniTest::Spec
  class << self; alias_method :__old_it, :it; end
  def self.it(desc="anonymous", opts={}, &block)
    if (FOCUS_MODE == true && opts[:focus] == true) || FOCUS_MODE == false
      __old_it(desc, &block)
    end
  end
end

require 'mocha'

Dir['test/extras/**/*'].reject {|i| File.directory?(i) }.each do |l|
  require l
end
