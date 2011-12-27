$: << File.dirname(__FILE__)

# Ruby 1.8.7 and others
unless :a_symbol.respond_to?(:<=>)
  class Symbol
    def <=>(other)
      self.to_s <=> other.to_s
    end
  end
end


require 'clive/error'
require 'clive/output'
require 'clive/version'
require 'clive/struct_hash'

require 'clive/formatter'
require 'clive/formatter/plain'
require 'clive/formatter/colour'
require 'clive/type'
require 'clive/argument'
require 'clive/arguments'
require 'clive/arguments/parser'
require 'clive/option/argument_parser'
require 'clive/option/runner'
require 'clive/option'
require 'clive/command'
require 'clive/parser'
require 'clive/base'


# Clive is a DSL for creating command line interfaces. Extend a class with it
# to use.
#
# @example
#
#   class CLI < Clive
#     opt :working, 'Test if it is working' do
#       puts "YEP!".green
#     end
#   end
#
#   CLI.run ARGV
#
#   # app.rb --working
#   #=> "YEP!"
#
class Clive

    extend Type::Lookup
    
    # @group Class style
    #
    # class CLI < Clive; opt :v, :verbose; end
    # s,a = CLI.run ARGV
    #
    
    class << self
      attr_accessor :instance
    end
  
    def self.inherited(klass)
      klass.instance = Base.new
      
      str = (Base.instance_methods(false) | Command.instance_methods(false)).map do |sym|
        <<-EOS
          def self.#{sym}(*args, &block)
            instance.send(:#{sym}, *args, &block)
          end
        EOS
      end.join("\n")
      klass.instance_eval str
    end
    
    def self.method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
    
    def self.respond_to_missing?(sym, include_private)
      instance.respond_to?(sym, include_private)
    end
    
    
    # @group Instance style
    #
    # c = Clive.new { opt :v, :verbose }
    # s,a = c.run ARGV
    # 
    
    attr_accessor :instance
    
    def initialize(&block)
      @instance = Base.new(&block)
    end
    
    def method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
    
    def respond_to_missing?(sym, include_private)
      instance.respond_to?(sym, include_private)
    end

end
