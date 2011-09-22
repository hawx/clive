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
require 'minitest/mock'
require 'minitest/autorun'

Dir['test/extras/**/*'].reject {|i| File.directory?(i) }.each do |l|
  require l
end
