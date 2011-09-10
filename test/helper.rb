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
require 'extras/hooks'

require 'minitest/autorun'
