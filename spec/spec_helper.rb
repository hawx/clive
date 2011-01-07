if RUBY_VERSION >= "1.9"
  require 'duvet'
  Duvet.start :filter => 'clive/lib'
end

require 'rspec'
require 'clive'
require 'shared_specs'

RSpec.configure do |config|
  config.color_enabled = true
end