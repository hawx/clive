$: << File.dirname(__FILE__) + '/..'

if RUBY_VERSION >= "1.9"
  require 'fileutils'
  require 'duvet'
  Duvet.start :filter => 'lib/clive'
end

require 'lib/clive'

gem 'minitest'

require 'minitest/unit'
require 'minitest/mock'
require 'minitest/autorun'

Dir['test/extras/**/*'].reject {|i| File.directory?(i) }.each do |l|
  require l
end
