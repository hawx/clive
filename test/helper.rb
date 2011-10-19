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
gem 'minitest'

require 'shellwords'

def s(str)
  Shellwords.split(str)
end

require 'minitest/unit'
require 'minitest/spec'
require 'minitest/mock'
require 'minitest/autorun'

module MiniTest::Expectations
  alias_method :must_have, :must_be
  alias_method :wont_have, :wont_be
  alias_method :this, :proc
  
  infect_an_assertion :assert, :must_be_true
  alias_method :wont_be_false, :must_be_true
  
  infect_an_assertion :refute, :must_be_false
  alias_method :wont_be_true, :must_be_false
  
  def must_be_argument(opts)
    opts.each do |k,v|
      self.instance_variable_get("@#{k}").must_equal v
    end
  end
end


Dir['test/extras/**/*'].reject {|i| File.directory?(i) }.each do |l|
  require l
end
