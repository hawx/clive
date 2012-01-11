# Allows you to write
#
#   it 'does something', :focus => true do
#     # ...
#   end
#
# and when ENV['FOCUS'] is set to 'true' it will only run tests with 
# `:focus => true`.
#
#   $ FOCUS=true bundler exec rake
#

FOCUS_MODE = ENV['FOCUS'] == 'true'

class MiniTest::Spec
  class << self; alias_method :__old_it, :it; end
  def self.it(desc="anonymous", opts={}, &block)
    if (FOCUS_MODE == true && opts[:focus] == true) || FOCUS_MODE == false
      __old_it(desc, &block)
    end
  end
end