# $: << File.join(File.dirname(__FILE__), '..')
# $: << File.dirname(__FILE__)
require 'duvet'
Duvet.start :filter => 'clive/lib'

require 'rspec'
require 'clive'
require 'shared_specs'

RSpec.configure do |config|
  config.color_enabled = true
end