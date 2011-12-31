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
  # class CLI < Clive
  #   opt :v, :verbose
  # end
  #
  # r = CLI.run ARGV
  #
  
  class << self
    attr_accessor :instance
    
    # Sets up proxy methods for each relevent method in {Base} to an instance of {Base}.
    def inherited(klass)
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
    
    def method_missing(sym, *args, &block)
      instance.send(sym, *args, &block)
    end
    
    def respond_to_missing?(sym, include_private)
      instance.respond_to?(sym, include_private)
    end
  end
  
  # @group Instance style
  #
  # c = Clive.new { opt :v, :verbose }
  # r = c.run ARGV
  # 
  
  # Proxy for Clive::Base.new
  def self.new(&block)
    Base.new(&block)
  end

end

# The quickest way to grab a few options. This form does not allow arguments or 
# commands! It is meant to be quick and simple.
#
# @example
#
#   r = Clive(:verbose, [:b, :bare]).run(%w(--verbose))
#   r.bare     #=> false
#   r.verbose  #=> true
#
#
#   # The above example is equivalent to 
#   r = Clive.new {
#     opt :verbose
#     opt :b, :bare
#   }.run(%w(--verbose))
#
# @param names [#to_sym, Array<#to_sym>] List of names to create options for
# @return [Clive] A clive instance setup with the correct options
#
def Clive(*names)
  c = Clive::Base.new
  names.each do |o|
    c.option *Array(o).map(&:to_sym)
  end
  c
end
